// Nen Net - Connection Module Tests
// Tests connection management and inline functions

const std = @import("std");
const net = @import("nen-net");

test "Connection initialization" {
    const connection_id: u64 = 12345;
    const conn = net.connection.Connection.init(connection_id);

    // Test initial state
    try std.testing.expectEqual(connection_id, conn.id);
    try std.testing.expect(!conn.is_active);
}

test "Connection lifecycle management" {
    var conn = net.connection.Connection.init(67890);

    // Test initial inactive state
    try std.testing.expect(!conn.is_active);

    // Test activation
    conn.activate();
    try std.testing.expect(conn.is_active);

    // Test deactivation
    conn.deactivate();
    try std.testing.expect(!conn.is_active);

    // Test reactivation
    conn.activate();
    try std.testing.expect(conn.is_active);
}

test "Multiple connections" {
    const connection_ids = [_]u64{ 1, 2, 3, 4, 5 };

    for (connection_ids) |id| {
        var conn = net.connection.Connection.init(id);

        // Test each connection has correct ID
        try std.testing.expectEqual(id, conn.id);
        try std.testing.expect(!conn.is_active);

        // Test activation
        conn.activate();
        try std.testing.expect(conn.is_active);

        // Test deactivation
        conn.deactivate();
        try std.testing.expect(!conn.is_active);
    }
}

test "Connection state transitions" {
    var conn = net.connection.Connection.init(99999);

    // Test multiple state transitions
    try std.testing.expect(!conn.is_active);

    conn.activate();
    try std.testing.expect(conn.is_active);

    conn.activate(); // Activating already active connection
    try std.testing.expect(conn.is_active);

    conn.deactivate();
    try std.testing.expect(!conn.is_active);

    conn.deactivate(); // Deactivating already inactive connection
    try std.testing.expect(!conn.is_active);

    conn.activate();
    try std.testing.expect(conn.is_active);
}

test "Connection with large IDs" {
    const large_ids = [_]u64{
        0xFFFFFFFFFFFFFFFF,
        0x8000000000000000,
        0x7FFFFFFFFFFFFFFF,
        0x1234567890ABCDEF,
    };

    for (large_ids) |id| {
        var conn = net.connection.Connection.init(id);
        try std.testing.expectEqual(id, conn.id);
        try std.testing.expect(!conn.is_active);

        // Test basic operations
        conn.activate();
        try std.testing.expect(conn.is_active);

        conn.deactivate();
        try std.testing.expect(!conn.is_active);
    }
}

test "Connection edge cases" {
    // Test with ID 0
    var conn_zero = net.connection.Connection.init(0);
    try std.testing.expectEqual(@as(u64, 0), conn_zero.id);
    try std.testing.expect(!conn_zero.is_active);

    // Test with ID 1
    var conn_one = net.connection.Connection.init(1);
    try std.testing.expectEqual(@as(u64, 1), conn_one.id);
    try std.testing.expect(!conn_one.is_active);

    // Test state changes
    conn_zero.activate();
    conn_one.activate();

    try std.testing.expect(conn_zero.is_active);
    try std.testing.expect(conn_one.is_active);

    conn_zero.deactivate();
    conn_one.deactivate();

    try std.testing.expect(!conn_zero.is_active);
    try std.testing.expect(!conn_one.is_active);
}

test "Connection performance" {
    const iterations = 1000;

    const start_time = std.time.nanoTimestamp();

    for (0..iterations) |i| {
        var conn = net.connection.Connection.init(@as(u64, @intCast(i)));
        conn.activate();
        conn.deactivate();
        conn.activate();
        conn.deactivate();
    }

    const end_time = std.time.nanoTimestamp();
    const total_time_ns = @as(u64, @intCast(end_time - start_time));
    const avg_time_ns = total_time_ns / iterations;

    // Each connection operation should be very fast (inline functions)
    try std.testing.expect(avg_time_ns < 1000); // Less than 1 microsecond per operation
}

test "Connection memory layout" {
    var conn = net.connection.Connection.init(12345);

    // Test that connection structure is compact
    const size = @sizeOf(net.connection.Connection);

    // Connection should be small (just u64 + bool)
    try std.testing.expect(size <= 16); // 8 bytes for u64 + 1 byte for bool + padding

    // Test alignment
    try std.testing.expect(@intFromPtr(&conn) % @alignOf(net.connection.Connection) == 0);
}

test "Connection concurrent operations" {
    var conn = net.connection.Connection.init(54321);

    // Test rapid state changes
    for (0..100) |_| {
        conn.activate();
        conn.deactivate();
    }

    // Final state should be inactive
    try std.testing.expect(!conn.is_active);

    // Test final activation
    conn.activate();
    try std.testing.expect(conn.is_active);
}
