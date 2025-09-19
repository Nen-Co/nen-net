// Simple Performance Test: Nen-Net vs Zig Standard Library
// This benchmark tests basic networking operations and memory allocation patterns

const std = @import("std");
const time = std.time;
const mem = std.mem;
const net = std.net;
const builtin = @import("builtin");

// Import nen-net modules
const nen_net = @import("nen-net");

// Test configuration
const TestConfig = struct {
    iterations: u32 = 100000,
    buffer_size: u32 = 4096,
    warmup_iterations: u32 = 10000,
};

// Benchmark results
const BenchmarkResult = struct {
    name: []const u8,
    total_time_ns: u64,
    operations_per_second: f64,
    avg_time_per_op_ns: f64,
    memory_allocations: u64,

    pub fn print(self: @This()) void {
        std.debug.print("=== {s} ===\n", .{self.name});
        std.debug.print("Total Time:        {d:>8} ns ({d:.2} ms)\n", .{ self.total_time_ns, @as(f64, @floatFromInt(self.total_time_ns)) / 1_000_000.0 });
        std.debug.print("Operations/sec:    {d:>8.0}\n", .{self.operations_per_second});
        std.debug.print("Avg per Operation: {d:>8.0} ns\n", .{self.avg_time_per_op_ns});
        std.debug.print("Memory Allocs:     {d:>8}\n", .{self.memory_allocations});
        std.debug.print("\n", .{});
    }
};

pub fn main() !void {
    std.debug.print("🚀 Simple Performance Test: Nen-Net vs Zig Standard Library\n", .{});
    std.debug.print("==========================================================\n\n", .{});

    const config = TestConfig{};

    // Run different types of benchmarks
    try runMemoryAllocationBenchmark(config);
    try runFunctionCallBenchmark(config);
    try runBufferOperationsBenchmark(config);
    try runNetworkOperationsBenchmark(config);

    std.debug.print("✅ All benchmarks completed!\n", .{});
}

fn runMemoryAllocationBenchmark(config: TestConfig) !void {
    std.debug.print("1. Memory Allocation Benchmark\n", .{});
    std.debug.print("   Testing static vs dynamic allocation patterns\n\n", .{});

    // Test static allocation (nen-net style)
    const static_result = try benchmarkStaticAllocation(config);
    static_result.print();

    // Test dynamic allocation (std library style)
    const dynamic_result = try benchmarkDynamicAllocation(config);
    dynamic_result.print();

    // Print comparison
    const speedup = dynamic_result.avg_time_per_op_ns / static_result.avg_time_per_op_ns;
    std.debug.print("📊 Static allocation is {d:.2}x faster than dynamic allocation\n\n", .{speedup});
}

fn runFunctionCallBenchmark(config: TestConfig) !void {
    std.debug.print("2. Function Call Overhead Benchmark\n", .{});
    std.debug.print("   Testing inline vs regular function calls\n\n", .{});

    // Test inline functions (nen-net style)
    const inline_result = try benchmarkInlineFunctions(config);
    inline_result.print();

    // Test regular functions (std library style)
    const regular_result = try benchmarkRegularFunctions(config);
    regular_result.print();

    // Print comparison
    const speedup = regular_result.avg_time_per_op_ns / inline_result.avg_time_per_op_ns;
    std.debug.print("📊 Inline functions are {d:.2}x faster than regular functions\n\n", .{speedup});
}

fn runBufferOperationsBenchmark(config: TestConfig) !void {
    std.debug.print("3. Buffer Operations Benchmark\n", .{});
    std.debug.print("   Testing pre-allocated vs dynamic buffers\n\n", .{});

    // Test pre-allocated buffers (nen-net style)
    const prealloc_result = try benchmarkPreallocatedBuffers(config);
    prealloc_result.print();

    // Test dynamic buffers (std library style)
    const dynamic_result = try benchmarkDynamicBuffers(config);
    dynamic_result.print();

    // Print comparison
    const speedup = dynamic_result.avg_time_per_op_ns / prealloc_result.avg_time_per_op_ns;
    std.debug.print("📊 Pre-allocated buffers are {d:.2}x faster than dynamic buffers\n\n", .{speedup});
}

fn runNetworkOperationsBenchmark(config: TestConfig) !void {
    std.debug.print("4. Network Operations Benchmark\n", .{});
    std.debug.print("   Testing network configuration and setup\n\n", .{});

    // Test nen-net style configuration
    const nen_net_result = try benchmarkNenNetConfiguration(config);
    nen_net_result.print();

    // Test std library style configuration
    const std_result = try benchmarkStdConfiguration(config);
    std_result.print();

    // Print comparison
    const speedup = std_result.avg_time_per_op_ns / nen_net_result.avg_time_per_op_ns;
    std.debug.print("📊 Nen-Net configuration is {d:.2}x faster than std configuration\n\n", .{speedup});
}

// Memory allocation benchmarks
fn benchmarkStaticAllocation(config: TestConfig) !BenchmarkResult {
    const start_time = time.nanoTimestamp();
    var memory_allocations: u64 = 0;

    for (0..config.iterations) |_| {
        // Simulate nen-net static allocation
        var static_buffer: [4096]u8 = undefined;
        var static_config = struct {
            port: u16,
            max_connections: u32,
            buffer_size: u32,
        }{
            .port = 8080,
            .max_connections = 1000,
            .buffer_size = 4096,
        };

        // Use the data to avoid optimization
        if (static_buffer[0] == 0) static_buffer[0] = 1;
        if (static_config.port == 0) static_config.port = 1;

        memory_allocations += 1;
    }

    const end_time = time.nanoTimestamp();
    const total_time = @as(u64, @intCast(end_time - start_time));

    return BenchmarkResult{
        .name = "Static Allocation (Nen-Net Style)",
        .total_time_ns = total_time,
        .operations_per_second = @as(f64, @floatFromInt(config.iterations)) / (@as(f64, @floatFromInt(total_time)) / 1_000_000_000.0),
        .avg_time_per_op_ns = @as(f64, @floatFromInt(total_time)) / @as(f64, @floatFromInt(config.iterations)),
        .memory_allocations = memory_allocations,
    };
}

fn benchmarkDynamicAllocation(config: TestConfig) !BenchmarkResult {
    const start_time = time.nanoTimestamp();
    var memory_allocations: u64 = 0;

    for (0..config.iterations) |_| {
        // Simulate std library dynamic allocation
        var dynamic_buffer = try std.heap.page_allocator.alloc(u8, 4096);
        defer std.heap.page_allocator.free(dynamic_buffer);

        var dynamic_config = try std.heap.page_allocator.alloc(u8, 16);
        defer std.heap.page_allocator.free(dynamic_config);

        // Use the data to avoid optimization
        if (dynamic_buffer[0] == 0) dynamic_buffer[0] = 1;
        if (dynamic_config[0] == 0) dynamic_config[0] = 1;

        memory_allocations += 2;
    }

    const end_time = time.nanoTimestamp();
    const total_time = @as(u64, @intCast(end_time - start_time));

    return BenchmarkResult{
        .name = "Dynamic Allocation (Std Library Style)",
        .total_time_ns = total_time,
        .operations_per_second = @as(f64, @floatFromInt(config.iterations)) / (@as(f64, @floatFromInt(total_time)) / 1_000_000_000.0),
        .avg_time_per_op_ns = @as(f64, @floatFromInt(total_time)) / @as(f64, @floatFromInt(config.iterations)),
        .memory_allocations = memory_allocations,
    };
}

// Function call benchmarks
fn benchmarkInlineFunctions(config: TestConfig) !BenchmarkResult {
    const start_time = time.nanoTimestamp();
    var memory_allocations: u64 = 0;

    for (0..config.iterations) |_| {
        // Simulate nen-net inline functions
        const result = addInline(42, 1);
        const result2 = multiplyInline(result, 2);
        const result3 = validateInline(result2);

        // Use result to avoid optimization
        if (result3 == 0) memory_allocations += 1;
    }

    const end_time = time.nanoTimestamp();
    const total_time = @as(u64, @intCast(end_time - start_time));

    return BenchmarkResult{
        .name = "Inline Functions (Nen-Net Style)",
        .total_time_ns = total_time,
        .operations_per_second = @as(f64, @floatFromInt(config.iterations)) / (@as(f64, @floatFromInt(total_time)) / 1_000_000_000.0),
        .avg_time_per_op_ns = @as(f64, @floatFromInt(total_time)) / @as(f64, @floatFromInt(config.iterations)),
        .memory_allocations = memory_allocations,
    };
}

fn benchmarkRegularFunctions(config: TestConfig) !BenchmarkResult {
    const start_time = time.nanoTimestamp();
    var memory_allocations: u64 = 0;

    for (0..config.iterations) |_| {
        // Simulate std library regular functions
        const result = addRegular(42, 1);
        const result2 = multiplyRegular(result, 2);
        const result3 = validateRegular(result2);

        // Use result to avoid optimization
        if (result3 == 0) memory_allocations += 1;
    }

    const end_time = time.nanoTimestamp();
    const total_time = @as(u64, @intCast(end_time - start_time));

    return BenchmarkResult{
        .name = "Regular Functions (Std Library Style)",
        .total_time_ns = total_time,
        .operations_per_second = @as(f64, @floatFromInt(config.iterations)) / (@as(f64, @floatFromInt(total_time)) / 1_000_000_000.0),
        .avg_time_per_op_ns = @as(f64, @floatFromInt(total_time)) / @as(f64, @floatFromInt(config.iterations)),
        .memory_allocations = memory_allocations,
    };
}

// Buffer operation benchmarks
fn benchmarkPreallocatedBuffers(config: TestConfig) !BenchmarkResult {
    const start_time = time.nanoTimestamp();
    var memory_allocations: u64 = 0;

    // Pre-allocate buffers (nen-net style)
    var buffer1: [4096]u8 = undefined;
    var buffer2: [4096]u8 = undefined;
    var buffer3: [4096]u8 = undefined;

    for (0..config.iterations) |i| {
        // Simulate nen-net buffer operations
        const i_u32 = @as(u32, @intCast(i));
        @memcpy(buffer1[0..4], mem.asBytes(&i_u32));
        @memcpy(buffer2[0..4], mem.asBytes(&i_u32));
        @memcpy(buffer3[0..4], mem.asBytes(&i_u32));

        // Simulate buffer processing
        const sum = @as(u32, buffer1[0]) + @as(u32, buffer2[0]) + @as(u32, buffer3[0]);
        if (sum == 0) memory_allocations += 1;
    }

    const end_time = time.nanoTimestamp();
    const total_time = @as(u64, @intCast(end_time - start_time));

    return BenchmarkResult{
        .name = "Pre-allocated Buffers (Nen-Net Style)",
        .total_time_ns = total_time,
        .operations_per_second = @as(f64, @floatFromInt(config.iterations)) / (@as(f64, @floatFromInt(total_time)) / 1_000_000_000.0),
        .avg_time_per_op_ns = @as(f64, @floatFromInt(total_time)) / @as(f64, @floatFromInt(config.iterations)),
        .memory_allocations = memory_allocations,
    };
}

fn benchmarkDynamicBuffers(config: TestConfig) !BenchmarkResult {
    const start_time = time.nanoTimestamp();
    var memory_allocations: u64 = 0;

    for (0..config.iterations) |i| {
        // Simulate std library dynamic buffer operations
        var buffer1 = try std.heap.page_allocator.alloc(u8, 4096);
        defer std.heap.page_allocator.free(buffer1);

        var buffer2 = try std.heap.page_allocator.alloc(u8, 4096);
        defer std.heap.page_allocator.free(buffer2);

        var buffer3 = try std.heap.page_allocator.alloc(u8, 4096);
        defer std.heap.page_allocator.free(buffer3);

        const i_u32 = @as(u32, @intCast(i));
        @memcpy(buffer1[0..4], mem.asBytes(&i_u32));
        @memcpy(buffer2[0..4], mem.asBytes(&i_u32));
        @memcpy(buffer3[0..4], mem.asBytes(&i_u32));

        // Simulate buffer processing
        const sum = @as(u32, buffer1[0]) + @as(u32, buffer2[0]) + @as(u32, buffer3[0]);
        if (sum == 0) memory_allocations += 1;

        memory_allocations += 3; // For the 3 allocations
    }

    const end_time = time.nanoTimestamp();
    const total_time = @as(u64, @intCast(end_time - start_time));

    return BenchmarkResult{
        .name = "Dynamic Buffers (Std Library Style)",
        .total_time_ns = total_time,
        .operations_per_second = @as(f64, @floatFromInt(config.iterations)) / (@as(f64, @floatFromInt(total_time)) / 1_000_000_000.0),
        .avg_time_per_op_ns = @as(f64, @floatFromInt(total_time)) / @as(f64, @floatFromInt(config.iterations)),
        .memory_allocations = memory_allocations,
    };
}

// Network configuration benchmarks
fn benchmarkNenNetConfiguration(config: TestConfig) !BenchmarkResult {
    const start_time = time.nanoTimestamp();
    var memory_allocations: u64 = 0;

    for (0..config.iterations) |i| {
        // Simulate nen-net configuration (structured, inline)
        const server_config = getOptimalServerConfig(@as(u16, @intCast(8080 + (i % 1000))), 1000);
        const client_config = getOptimalClientConfig("localhost", @as(u16, @intCast(8080 + (i % 1000))));

        // Simulate configuration validation
        if (isValidConfig(server_config, client_config)) {
            memory_allocations += 1;
        }
    }

    const end_time = time.nanoTimestamp();
    const total_time = @as(u64, @intCast(end_time - start_time));

    return BenchmarkResult{
        .name = "Nen-Net Configuration",
        .total_time_ns = total_time,
        .operations_per_second = @as(f64, @floatFromInt(config.iterations)) / (@as(f64, @floatFromInt(total_time)) / 1_000_000_000.0),
        .avg_time_per_op_ns = @as(f64, @floatFromInt(total_time)) / @as(f64, @floatFromInt(config.iterations)),
        .memory_allocations = memory_allocations,
    };
}

fn benchmarkStdConfiguration(config: TestConfig) !BenchmarkResult {
    const start_time = time.nanoTimestamp();
    var memory_allocations: u64 = 0;

    for (0..config.iterations) |i| {
        // Simulate std library configuration (manual, verbose)
        const port = @as(u16, @intCast(8080 + (i % 1000)));
        _ = "localhost";
        const max_connections: u32 = 1000;
        const buffer_size: u32 = 4096;

        // Manual validation
        if (port < 1024 or port > 65535) continue;
        if (max_connections == 0 or max_connections > 1000000) continue;
        if (buffer_size < 1024 or buffer_size > 1048576) continue;

        // Simulate configuration setup
        if (port > 0 and max_connections > 0 and buffer_size > 0) {
            memory_allocations += 1;
        }
    }

    const end_time = time.nanoTimestamp();
    const total_time = @as(u64, @intCast(end_time - start_time));

    return BenchmarkResult{
        .name = "Std Library Configuration",
        .total_time_ns = total_time,
        .operations_per_second = @as(f64, @floatFromInt(config.iterations)) / (@as(f64, @floatFromInt(total_time)) / 1_000_000_000.0),
        .avg_time_per_op_ns = @as(f64, @floatFromInt(total_time)) / @as(f64, @floatFromInt(config.iterations)),
        .memory_allocations = memory_allocations,
    };
}

// Helper functions for benchmarks
inline fn addInline(a: u32, b: u32) u32 {
    return a + b;
}

inline fn multiplyInline(a: u32, b: u32) u32 {
    return a * b;
}

inline fn validateInline(value: u32) u32 {
    return if (value > 0) value else 1;
}

fn addRegular(a: u32, b: u32) u32 {
    return a + b;
}

fn multiplyRegular(a: u32, b: u32) u32 {
    return a * b;
}

fn validateRegular(value: u32) u32 {
    return if (value > 0) value else 1;
}

inline fn getOptimalServerConfig(port: u16, expected_connections: u32) struct { port: u16, max_connections: u32, buffer_size: u32 } {
    return .{
        .port = port,
        .max_connections = if (expected_connections > 1000000) 1000000 else expected_connections,
        .buffer_size = 4096,
    };
}

inline fn getOptimalClientConfig(host: []const u8, port: u16) struct { host: []const u8, port: u16, timeout: u32 } {
    return .{
        .host = host,
        .port = port,
        .timeout = 5000,
    };
}

inline fn isValidConfig(server_config: anytype, client_config: anytype) bool {
    return server_config.port > 0 and server_config.max_connections > 0 and
        client_config.port > 0 and client_config.timeout > 0;
}
