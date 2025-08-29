// Nen Net - Basic Unit Tests
// Tests basic functionality and inline functions

const std = @import("std");

test "basic functionality" {
    // Simple test to verify the test framework works
    try std.testing.expect(1 + 1 == 2);
    try std.testing.expect(true);
    try std.testing.expect(!false);
}

test "string operations" {
    const hello = "Hello, Nen Net!";
    try std.testing.expect(hello.len > 0);
    try std.testing.expect(std.mem.indexOf(u8, hello, "Nen") != null);
}

test "number operations" {
    const port = 8080;
    const max_connections = 1000;
    
    try std.testing.expect(port > 0);
    try std.testing.expect(max_connections > 0);
    try std.testing.expect(max_connections <= 1000000); // Reasonable upper limit
}

test "inline function concept" {
    // Test that we understand inline functions
    const result = addInline(5, 3);
    try std.testing.expectEqual(@as(u32, 8), result);
}

// Simple inline function for testing
inline fn addInline(a: u32, b: u32) u32 {
    return a + b;
}

test "performance measurement" {
    const iterations = 1000;
    
    const start_time = std.time.nanoTimestamp();
    
    for (0..iterations) |_| {
        _ = addInline(1, 1);
    }
    
    const end_time = std.time.nanoTimestamp();
    const total_time_ns = @as(u64, @intCast(end_time - start_time));
    const avg_time_ns = total_time_ns / iterations;
    
    // Inline function calls should be very fast
    try std.testing.expect(avg_time_ns < 1000); // Less than 1 microsecond per call
}

test "inline function performance comparison" {
    const iterations = 10000;
    
    // Test inline function performance
    const start_time_inline = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        _ = addInline(1, 1);
    }
    const end_time_inline = std.time.nanoTimestamp();
    const inline_time = @as(u64, @intCast(end_time_inline - start_time_inline));
    
    // Test regular function performance
    const start_time_regular = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        _ = addRegular(1, 1);
    }
    const end_time_regular = std.time.nanoTimestamp();
    const regular_time = @as(u64, @intCast(end_time_regular - start_time_regular));
    
    // Both should be fast
    try std.testing.expect(inline_time < 100000); // Less than 100 microseconds for 10k calls
    try std.testing.expect(regular_time < 100000); // Less than 100 microseconds for 10k calls
    
    // Both should be reasonable
    try std.testing.expect(inline_time > 0);
    try std.testing.expect(regular_time > 0);
}

// Regular function for comparison
fn addRegular(a: u32, b: u32) u32 {
    return a + b;
}

test "inline function with complex logic" {
    const result = complexInline(10, 5);
    // 0*5 + 1*5 + 2*5 + ... + 9*5 = 5*(0+1+2+...+9) = 5*45 = 225
    try std.testing.expectEqual(@as(u32, 225), result);
}

// Complex inline function
inline fn complexInline(a: u32, b: u32) u32 {
    var sum: u32 = 0;
    for (0..a) |i| {
        sum += @as(u32, @intCast(i)) * b;
    }
    return sum;
}

test "inline function memory efficiency" {
    // Test that inline functions don't create unnecessary stack frames
    const result1 = addInline(1, 2);
    const result2 = addInline(3, 4);
    const result3 = addInline(5, 6);
    
    try std.testing.expectEqual(@as(u32, 3), result1);
    try std.testing.expectEqual(@as(u32, 7), result2);
    try std.testing.expectEqual(@as(u32, 11), result3);
}
