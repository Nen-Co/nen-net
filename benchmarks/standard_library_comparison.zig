// Standard Library Comparison Benchmarks
// This file demonstrates performance differences between nen-net style and std library

const std = @import("std");
const time = std.time;
const mem = std.mem;
const net = std.net;
const http = std.http;

// Mock structures representing nen-net's approach
const ServerConfig = struct {
    port: u16,
    max_connections: u32,
    request_buffer_size: u32,
    response_buffer_size: u32,
};

const ClientConfig = struct {
    host: []const u8,
    port: u16,
    buffer_size: u32,
};

// Mock inline functions representing nen-net's approach
inline fn getOptimalServerConfig(port: u16, expected_connections: u32) ServerConfig {
    return ServerConfig{
        .port = port,
        .max_connections = if (expected_connections > 1000000) 1000000 else expected_connections,
        .request_buffer_size = 8192,
        .response_buffer_size = 16384,
    };
}

inline fn isValidPort(port: u16) bool {
    return port >= 1024 and port <= 65535;
}

inline fn isValidBufferSize(size: u32) bool {
    return size >= 1024 and size <= 1048576;
}

inline fn isValidConnectionCount(count: u32) bool {
    return count > 0 and count <= 1000000;
}

pub fn main() !void {
    std.debug.print("=== Nen-Net Style vs Standard Library Comparison ===\n\n", .{});

    try benchmarkMemoryAllocation();
    try benchmarkFunctionCallOverhead();
    try benchmarkBufferOperations();
    try benchmarkConfigurationSetup();

    std.debug.print("\nBenchmark completed!\n", .{});
}

fn benchmarkMemoryAllocation() !void {
    std.debug.print("1. Memory Allocation Benchmark\n", .{});
    std.debug.print("   Testing static vs dynamic allocation patterns\n\n", .{});

    // Test nen-net style (static allocation)
    var start_time = time.nanoTimestamp();
    _ = ServerConfig{
        .port = 8080,
        .max_connections = 1000,
        .request_buffer_size = 8192,
        .response_buffer_size = 16384,
    };
    var end_time = time.nanoTimestamp();
    const static_time = @as(u64, @intCast(end_time - start_time));

    // Test standard library style (dynamic allocation)
    start_time = time.nanoTimestamp();
    var dynamic_buffers: [1000][]u8 = undefined;
    for (0..1000) |i| {
        dynamic_buffers[i] = try std.heap.page_allocator.alloc(u8, 8192);
    }
    end_time = time.nanoTimestamp();
    const dynamic_time = @as(u64, @intCast(end_time - start_time));

    // Cleanup dynamic allocations
    for (dynamic_buffers) |buffer| {
        std.heap.page_allocator.free(buffer);
    }

    std.debug.print("   Static allocation (nen-net style): {d:>8} ns\n", .{@as(f64, @floatFromInt(static_time))});
    std.debug.print("   Dynamic allocation (std):           {d:>8} ns\n", .{@as(f64, @floatFromInt(dynamic_time))});
    std.debug.print("   Speedup: {d:>8.2}x\n\n", .{@as(f64, @floatFromInt(dynamic_time)) / @as(f64, @floatFromInt(static_time))});
}

fn benchmarkFunctionCallOverhead() !void {
    std.debug.print("2. Function Call Overhead Benchmark\n", .{});
    std.debug.print("   Testing inline vs regular function calls\n\n", .{});

    const iterations = 100000;

    // Test inline function (nen-net style)
    var start_time = time.nanoTimestamp();
    var sum: u64 = 0;
    for (0..iterations) |i| {
        sum += addInline(@as(u32, @intCast(i)), 1);
    }
    var end_time = time.nanoTimestamp();
    const inline_time = @as(u64, @intCast(end_time - start_time));

    // Test regular function (standard library style)
    start_time = time.nanoTimestamp();
    sum = 0;
    for (0..iterations) |i| {
        sum += addRegular(@as(u32, @intCast(i)), 1);
    }
    end_time = time.nanoTimestamp();
    const regular_time = @as(u64, @intCast(end_time - start_time));

    std.debug.print("   Inline function calls: {d:>8} ns\n", .{@as(f64, @floatFromInt(inline_time))});
    std.debug.print("   Regular function calls: {d:>8} ns\n", .{@as(f64, @floatFromInt(regular_time))});
    std.debug.print("   Speedup: {d:>8.2}x\n\n", .{@as(f64, @floatFromInt(regular_time)) / @as(f64, @floatFromInt(inline_time))});
}

fn benchmarkBufferOperations() !void {
    std.debug.print("3. Buffer Operations Benchmark\n", .{});
    std.debug.print("   Testing pre-allocated vs dynamic buffers\n\n", .{});

    const buffer_size = 8192;
    const iterations = 10000;

    // Test nen-net style (pre-allocated buffer)
    var static_buffer: [buffer_size]u8 = undefined;
    var start_time = time.nanoTimestamp();
    for (0..iterations) |i| {
        const i_u32 = @as(u32, @intCast(i));
        @memcpy(static_buffer[0..4], mem.asBytes(&i_u32));
        // Use static_buffer to avoid unused variable warning
        if (static_buffer[0] == 0) continue;
    }
    var end_time = time.nanoTimestamp();
    const static_time = @as(u64, @intCast(end_time - start_time));

    // Test standard library style (dynamic buffer allocation)
    start_time = time.nanoTimestamp();
    for (0..iterations) |i| {
        var dynamic_buffer = try std.heap.page_allocator.alloc(u8, buffer_size);
        const i_u32 = @as(u32, @intCast(i));
        @memcpy(dynamic_buffer[0..4], mem.asBytes(&i_u32));
        // Use dynamic_buffer to avoid unused variable warning
        if (dynamic_buffer[0] == 0) continue;
        std.heap.page_allocator.free(dynamic_buffer);
    }
    end_time = time.nanoTimestamp();
    const dynamic_time = @as(u64, @intCast(end_time - start_time));

    std.debug.print("   Pre-allocated buffer: {d:>8} ns\n", .{@as(f64, @floatFromInt(static_time))});
    std.debug.print("   Dynamic buffer:       {d:>8} ns\n", .{@as(f64, @floatFromInt(dynamic_time))});
    std.debug.print("   Speedup: {d:>8.2}x\n\n", .{@as(f64, @floatFromInt(dynamic_time)) / @as(f64, @floatFromInt(static_time))});
}

fn benchmarkConfigurationSetup() !void {
    std.debug.print("4. Configuration Setup Benchmark\n", .{});
    std.debug.print("   Testing structured vs manual configuration\n\n", .{});

    const iterations = 10000;

    // Test nen-net style (structured configuration)
    var start_time = time.nanoTimestamp();
    for (0..iterations) |i| {
        _ = getOptimalServerConfig(@as(u16, @intCast(8080 + (i % 1000))), 1000);
    }
    var end_time = time.nanoTimestamp();
    const structured_time = @as(u64, @intCast(end_time - start_time));

    // Test standard library style (manual configuration)
    start_time = time.nanoTimestamp();
    for (0..iterations) |i| {
        const port: u16 = @as(u16, @intCast(8080 + (i % 1000)));
        const max_conn: u32 = 1000;
        const req_buf: u32 = 8192;
        const resp_buf: u32 = 16384;

        // Manual validation
        if (port < 1024 or port > 65535) continue;
        if (max_conn == 0 or max_conn > 1000000) continue;
        if (req_buf < 1024 or req_buf > 1048576) continue;
        if (resp_buf < 1024 or resp_buf > 1048576) continue;

        // Use variables to avoid unused variable warnings
        if (port == 0 or max_conn == 0 or req_buf == 0 or resp_buf == 0) continue;
    }
    end_time = time.nanoTimestamp();
    const manual_time = @as(u64, @intCast(end_time - start_time));

    std.debug.print("   Structured config (nen-net style): {d:>8} ns\n", .{@as(f64, @floatFromInt(structured_time))});
    std.debug.print("   Manual config (std):               {d:>8} ns\n", .{@as(f64, @floatFromInt(manual_time))});
    std.debug.print("   Speedup: {d:>8.2}x\n\n", .{@as(f64, @floatFromInt(manual_time)) / @as(f64, @floatFromInt(structured_time))});
}

// Inline function (nen-net style)
inline fn addInline(a: u32, b: u32) u32 {
    return a + b;
}

// Regular function (standard library style)
fn addRegular(a: u32, b: u32) u32 {
    return a + b;
}
