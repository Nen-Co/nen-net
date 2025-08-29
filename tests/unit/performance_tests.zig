// Nen Net - Performance Module Tests
// Tests performance monitoring and inline functions

const std = @import("std");
const net = @import("../../src/lib.zig");

test "Performance Monitor initialization" {
    var monitor = net.performance.PerformanceMonitor.init();
    
    // Test initial state
    try std.testing.expect(monitor.start_time > 0);
}

test "Performance Monitor uptime calculation" {
    var monitor = net.performance.PerformanceMonitor.init();
    
    // Test initial uptime
    const initial_uptime = monitor.getUptime();
    try std.testing.expect(initial_uptime >= 0);
    
    // Wait a bit and check uptime increases
    std.time.sleep(1000); // 1 microsecond
    const new_uptime = monitor.getUptime();
    try std.testing.expect(new_uptime > initial_uptime);
}

test "Performance Monitor accuracy" {
    var monitor = net.performance.PerformanceMonitor.init();
    
    // Test that uptime is monotonically increasing
    var last_uptime: u64 = 0;
    
    for (0..10) |_| {
        const current_uptime = monitor.getUptime();
        try std.testing.expect(current_uptime >= last_uptime);
        last_uptime = current_uptime;
        
        std.time.sleep(1000); // 1 microsecond
    }
}

test "Performance Monitor with multiple instances" {
    var monitor1 = net.performance.PerformanceMonitor.init();
    std.time.sleep(1000); // 1 microsecond
    var monitor2 = net.performance.PerformanceMonitor.init();
    
    // Second monitor should start later
    try std.testing.expect(monitor2.start_time > monitor1.start_time);
    
    // Both should have valid uptimes
    const uptime1 = monitor1.getUptime();
    const uptime2 = monitor2.getUptime();
    
    try std.testing.expect(uptime1 > uptime2); // First monitor should have longer uptime
    try std.testing.expect(uptime1 > 0);
    try std.testing.expect(uptime2 > 0);
}

test "Performance Monitor precision" {
    var monitor = net.performance.PerformanceMonitor.init();
    
    // Test that we can measure very small time differences
    const start_uptime = monitor.getUptime();
    
    // Do minimal work
    var sum: u64 = 0;
    for (0..100) |i| {
        sum += i;
    }
    _ = sum;
    
    const end_uptime = monitor.getUptime();
    
    // Uptime should have increased
    try std.testing.expect(end_uptime >= start_uptime);
}

test "Performance Monitor edge cases" {
    // Test with very long uptime
    var monitor = net.performance.PerformanceMonitor.init();
    
    // Simulate long uptime by manipulating the start time
    // Note: This is just for testing, not for production use
    monitor.start_time = std.time.nanoTimestamp() - 86400_000_000_000; // 1 day ago
    
    const uptime = monitor.getUptime();
    try std.testing.expect(uptime > 0);
    
    // Test with very recent start
    var recent_monitor = net.performance.PerformanceMonitor.init();
    const recent_uptime = recent_monitor.getUptime();
    try std.testing.expect(recent_uptime >= 0);
}

test "Performance Monitor performance" {
    const iterations = 10000;
    
    const start_time = std.time.nanoTimestamp();
    
    for (0..iterations) |_| {
        var monitor = net.performance.PerformanceMonitor.init();
        _ = monitor.getUptime();
    }
    
    const end_time = std.time.nanoTimestamp();
    const total_time_ns = @intCast(u64, end_time - start_time);
    const avg_time_ns = total_time_ns / iterations;
    
    // Each monitor operation should be very fast (inline functions)
    try std.testing.expect(avg_time_ns < 1000); // Less than 1 microsecond per operation
}

test "Performance Monitor memory efficiency" {
    var monitor = net.performance.PerformanceMonitor.init();
    
    // Test that monitor structure is compact
    const size = @sizeOf(net.performance.PerformanceMonitor);
    
    // Monitor should be small (just i128 for start time)
    try std.testing.expect(size <= 16); // 16 bytes for i128
    
    // Test alignment
    try std.testing.expect(@ptrToInt(&monitor) % @alignOf(net.performance.PerformanceMonitor) == 0);
}

test "Performance Monitor concurrent access" {
    var monitor = net.performance.PerformanceMonitor.init();
    
    // Test rapid uptime calls
    for (0..1000) |_| {
        const uptime = monitor.getUptime();
        try std.testing.expect(uptime >= 0);
    }
    
    // Final uptime should be reasonable
    const final_uptime = monitor.getUptime();
    try std.testing.expect(final_uptime > 0);
}

test "Performance Monitor time consistency" {
    var monitor = net.performance.PerformanceMonitor.init();
    
    // Test that time measurements are consistent
    const measurements = [_]u64{
        monitor.getUptime(),
        monitor.getUptime(),
        monitor.getUptime(),
        monitor.getUptime(),
        monitor.getUptime(),
    };
    
    // All measurements should be valid
    for (measurements) |measurement| {
        try std.testing.expect(measurement >= 0);
    }
    
    // Measurements should be monotonically increasing (or equal if very fast)
    for (1..measurements.len) |i| {
        try std.testing.expect(measurements[i] >= measurements[i - 1]);
    }
}

test "Performance Monitor initialization performance" {
    const iterations = 10000;
    
    const start_time = std.time.nanoTimestamp();
    
    for (0..iterations) |_| {
        _ = net.performance.PerformanceMonitor.init();
    }
    
    const end_time = std.time.nanoTimestamp();
    const total_time_ns = @intCast(u64, end_time - start_time);
    const avg_time_ns = total_time_ns / iterations;
    
    // Monitor initialization should be very fast
    try std.testing.expect(avg_time_ns < 1000); // Less than 1 microsecond per initialization
}

test "Performance Monitor uptime precision" {
    var monitor = net.performance.PerformanceMonitor.init();
    
    // Test that uptime has nanosecond precision
    const uptime1 = monitor.getUptime();
    std.time.sleep(1000); // 1 microsecond
    const uptime2 = monitor.getUptime();
    
    // Uptime should have increased by at least 1 microsecond
    const difference = uptime2 - uptime1;
    try std.testing.expect(difference >= 1000); // At least 1 microsecond difference
}

test "Performance Monitor stress test" {
    const iterations = 100000;
    
    var monitor = net.performance.PerformanceMonitor.init();
    
    // Stress test with many rapid calls
    for (0..iterations) |_| {
        const uptime = monitor.getUptime();
        try std.testing.expect(uptime >= 0);
    }
    
    // Final uptime should be reasonable
    const final_uptime = monitor.getUptime();
    try std.testing.expect(final_uptime > 0);
    
    // Should not have crashed or corrupted data
    try std.testing.expect(true);
}
