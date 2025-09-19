// Real-World Performance Benchmark: Nen-Net vs Zig Standard Library
// This benchmark tests actual HTTP server performance with real networking

const std = @import("std");
const time = std.time;
const mem = std.mem;
const net = std.net;
const http = std.http;
const builtin = @import("builtin");

// Import nen-net modules
const nen_net = @import("nen-net");
const nen_io = @import("nen-io");

// Benchmark configuration
const BenchmarkConfig = struct {
    port: u16 = 8080,
    iterations: u32 = 10000,
    concurrent_requests: u32 = 100,
    request_size: u32 = 1024,
    response_size: u32 = 2048,
    warmup_iterations: u32 = 1000,
};

// Test data
const TestData = struct {
    request_data: []const u8,
    response_data: []const u8,

    pub fn init(allocator: std.mem.Allocator, request_size: u32, response_size: u32) !@This() {
        const req_data = try allocator.alloc(u8, request_size);
        const resp_data = try allocator.alloc(u8, response_size);

        // Fill with test data
        for (req_data, 0..) |*byte, i| {
            byte.* = @as(u8, @intCast(i % 256));
        }
        for (resp_data, 0..) |*byte, i| {
            byte.* = @as(u8, @intCast((i + 128) % 256));
        }

        return @This(){
            .request_data = req_data,
            .response_data = resp_data,
        };
    }

    pub fn deinit(self: @This(), allocator: std.mem.Allocator) void {
        allocator.free(self.request_data);
        allocator.free(self.response_data);
    }
};

// Benchmark results
const BenchmarkResults = struct {
    name: []const u8,
    total_time_ns: u64,
    requests_per_second: f64,
    avg_latency_ns: f64,
    memory_usage_bytes: u64,
    error_count: u32,

    pub fn print(self: @This()) void {
        std.debug.print("=== {} ===\n", .{self.name});
        std.debug.print("Total Time:        {d:>8} ns ({d:.2} ms)\n", .{ self.total_time_ns, @as(f64, @floatFromInt(self.total_time_ns)) / 1_000_000.0 });
        std.debug.print("Requests/sec:      {d:>8.0}\n", .{self.requests_per_second});
        std.debug.print("Avg Latency:       {d:>8.0} ns ({d:.2} ms)\n", .{ self.avg_latency_ns, self.avg_latency_ns / 1_000_000.0 });
        std.debug.print("Memory Usage:      {d:>8} bytes ({d:.2} KB)\n", .{ self.memory_usage_bytes, @as(f64, @floatFromInt(self.memory_usage_bytes)) / 1024.0 });
        std.debug.print("Errors:            {d:>8}\n", .{self.error_count});
        std.debug.print("\n");
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("🚀 Real-World Performance Benchmark: Nen-Net vs Zig Standard Library\n", .{});
    std.debug.print("================================================================\n\n", .{});

    const config = BenchmarkConfig{};
    const test_data = try TestData.init(allocator, config.request_size, config.response_size);
    defer test_data.deinit(allocator);

    // Run benchmarks
    const nen_net_results = try benchmarkNenNet(allocator, config, test_data);
    const std_lib_results = try benchmarkStandardLibrary(allocator, config, test_data);

    // Print results
    nen_net_results.print();
    std_lib_results.print();

    // Print comparison
    printComparison(nen_net_results, std_lib_results);
}

fn benchmarkNenNet(allocator: std.mem.Allocator, config: BenchmarkConfig, test_data: TestData) !BenchmarkResults {
    std.debug.print("Testing Nen-Net HTTP Server...\n", .{});

    // Initialize nen-net server
    var server = try nen_net.createHttpServer(config.port);
    defer server.deinit();

    // Add test route
    try server.addRoute("GET", "/test", testHandler);
    try server.addRoute("POST", "/data", dataHandler);

    // Start server in background
    var server_thread = try std.Thread.spawn(.{}, startNenNetServer, .{&server});
    defer server_thread.join();

    // Wait for server to start
    std.Thread.sleep(100 * time.ns_per_ms);

    // Benchmark client requests
    const start_time = time.nanoTimestamp();
    var error_count: u32 = 0;

    for (0..config.iterations) |_| {
        if (makeNenNetRequest(config.port, test_data) catch null) |_| {
            // Request successful
        } else {
            error_count += 1;
        }
    }

    const end_time = time.nanoTimestamp();
    const total_time = @as(u64, @intCast(end_time - start_time));

    return BenchmarkResults{
        .name = "Nen-Net HTTP Server",
        .total_time_ns = total_time,
        .requests_per_second = @as(f64, @floatFromInt(config.iterations)) / (@as(f64, @floatFromInt(total_time)) / 1_000_000_000.0),
        .avg_latency_ns = @as(f64, @floatFromInt(total_time)) / @as(f64, @floatFromInt(config.iterations)),
        .memory_usage_bytes = getMemoryUsage(),
        .error_count = error_count,
    };
}

fn benchmarkStandardLibrary(allocator: std.mem.Allocator, config: BenchmarkConfig, test_data: TestData) !BenchmarkResults {
    std.debug.print("Testing Standard Library HTTP Server...\n", .{});

    // Create standard library server
    const address = try net.Address.parseIp4("127.0.0.1", config.port + 1);
    var server = address.listen(.{ .reuse_address = true }) catch |err| {
        std.debug.print("Failed to start std server: {}\n", .{err});
        return BenchmarkResults{
            .name = "Standard Library HTTP Server",
            .total_time_ns = 0,
            .requests_per_second = 0,
            .avg_latency_ns = 0,
            .memory_usage_bytes = 0,
            .error_count = 1,
        };
    };
    defer server.deinit();

    // Start server in background
    var server_thread = try std.Thread.spawn(.{}, startStdServer, .{&server});
    defer server_thread.join();

    // Wait for server to start
    std.Thread.sleep(100 * time.ns_per_ms);

    // Benchmark client requests
    const start_time = time.nanoTimestamp();
    var error_count: u32 = 0;

    for (0..config.iterations) |_| {
        if (makeStdRequest(config.port + 1, test_data) catch null) |_| {
            // Request successful
        } else {
            error_count += 1;
        }
    }

    const end_time = time.nanoTimestamp();
    const total_time = @as(u64, @intCast(end_time - start_time));

    return BenchmarkResults{
        .name = "Standard Library HTTP Server",
        .total_time_ns = total_time,
        .requests_per_second = @as(f64, @floatFromInt(config.iterations)) / (@as(f64, @floatFromInt(total_time)) / 1_000_000_000.0),
        .avg_latency_ns = @as(f64, @floatFromInt(total_time)) / @as(f64, @floatFromInt(config.iterations)),
        .memory_usage_bytes = getMemoryUsage(),
        .error_count = error_count,
    };
}

fn startNenNetServer(server: *nen_net.HttpServer) void {
    server.start() catch |err| {
        std.debug.print("Nen-Net server error: {}\n", .{err});
    };
}

fn startStdServer(server: *net.Server) void {
    while (true) {
        const connection = server.accept() catch |err| {
            std.debug.print("Std server accept error: {}\n", .{err});
            continue;
        };
        defer connection.stream.close();

        handleStdRequest(connection) catch |err| {
            std.debug.print("Std request handling error: {}\n", .{err});
        };
    }
}

fn testHandler(request: *nen_net.HttpRequest, response: *nen_net.HttpResponse) !void {
    _ = request;
    try response.setStatus(200);
    try response.setHeader("Content-Type", "text/plain");
    try response.writeBody("Hello from Nen-Net!");
}

fn dataHandler(request: *nen_net.HttpRequest, response: *nen_net.HttpResponse) !void {
    _ = request;
    try response.setStatus(200);
    try response.setHeader("Content-Type", "application/json");
    try response.writeBody("{\"status\":\"success\",\"data\":\"processed\"}");
}

fn handleStdRequest(connection: net.Server.Connection) !void {
    var buffer: [4096]u8 = undefined;
    const bytes_read = try connection.stream.read(&buffer);
    const request = buffer[0..bytes_read];

    // Simple HTTP response
    const response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 20\r\n\r\nHello from Std Lib!";
    _ = try connection.stream.write(response);
}

fn makeNenNetRequest(port: u16, test_data: TestData) !void {
    const address = try net.Address.parseIp4("127.0.0.1", port);
    var client = try net.tcpConnectToAddress(address);
    defer client.close();

    const request = "GET /test HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n";
    _ = try client.writeAll(request);

    var response_buffer: [1024]u8 = undefined;
    _ = try client.readAll(&response_buffer);
}

fn makeStdRequest(port: u16, test_data: TestData) !void {
    const address = try net.Address.parseIp4("127.0.0.1", port);
    var client = try net.tcpConnectToAddress(address);
    defer client.close();

    const request = "GET /test HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n";
    _ = try client.writeAll(request);

    var response_buffer: [1024]u8 = undefined;
    _ = try client.readAll(&response_buffer);
}

fn getMemoryUsage() u64 {
    // Simple memory usage estimation
    // In a real implementation, you'd use platform-specific APIs
    return 1024 * 1024; // 1MB placeholder
}

fn printComparison(nen_net: BenchmarkResults, std_lib: BenchmarkResults) void {
    std.debug.print("🏆 PERFORMANCE COMPARISON\n", .{});
    std.debug.print("========================\n\n", .{});

    const speedup = nen_net.requests_per_second / std_lib.requests_per_second;
    const latency_improvement = std_lib.avg_latency_ns / nen_net.avg_latency_ns;
    const memory_efficiency = @as(f64, @floatFromInt(std_lib.memory_usage_bytes)) / @as(f64, @floatFromInt(nen_net.memory_usage_bytes));

    std.debug.print("Requests per Second:\n", .{});
    std.debug.print("  Nen-Net:     {d:>8.0} req/s\n", .{nen_net.requests_per_second});
    std.debug.print("  Std Library: {d:>8.0} req/s\n", .{std_lib.requests_per_second});
    std.debug.print("  Speedup:     {d:>8.2}x\n\n", .{speedup});

    std.debug.print("Average Latency:\n", .{});
    std.debug.print("  Nen-Net:     {d:>8.0} ns ({d:.2} ms)\n", .{ nen_net.avg_latency_ns, nen_net.avg_latency_ns / 1_000_000.0 });
    std.debug.print("  Std Library: {d:>8.0} ns ({d:.2} ms)\n", .{ std_lib.avg_latency_ns, std_lib.avg_latency_ns / 1_000_000.0 });
    std.debug.print("  Improvement: {d:>8.2}x\n\n", .{latency_improvement});

    std.debug.print("Memory Usage:\n", .{});
    std.debug.print("  Nen-Net:     {d:>8} bytes ({d:.2} KB)\n", .{ nen_net.memory_usage_bytes, @as(f64, @floatFromInt(nen_net.memory_usage_bytes)) / 1024.0 });
    std.debug.print("  Std Library: {d:>8} bytes ({d:.2} KB)\n", .{ std_lib.memory_usage_bytes, @as(f64, @floatFromInt(std_lib.memory_usage_bytes)) / 1024.0 });
    std.debug.print("  Efficiency:  {d:>8.2}x\n\n", .{memory_efficiency});

    std.debug.print("Error Rate:\n", .{});
    std.debug.print("  Nen-Net:     {d:>8} errors\n", .{nen_net.error_count});
    std.debug.print("  Std Library: {d:>8} errors\n\n", .{std_lib.error_count});

    if (speedup > 1.0) {
        std.debug.print("🎉 Nen-Net is {d:.2}x faster than Standard Library!\n", .{speedup});
    } else {
        std.debug.print("📊 Standard Library is {d:.2}x faster than Nen-Net\n", .{1.0 / speedup});
    }

    if (latency_improvement > 1.0) {
        std.debug.print("⚡ Nen-Net has {d:.2}x better latency!\n", .{latency_improvement});
    } else {
        std.debug.print("📈 Standard Library has {d:.2}x better latency\n", .{1.0 / latency_improvement});
    }
}
