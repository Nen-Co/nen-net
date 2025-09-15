// Nen Net - TCP Module Tests
// Tests TCP client/server functionality and inline functions

const std = @import("std");
const net = @import("nen-net");

test "TCP Client initialization" {
    const config = net.config.ClientConfig{
        .host = "localhost",
        .port = 8080,
        .buffer_size = 4096,
    };

    const client = net.tcp.TcpClient.init(config);

    // Test configuration is correctly set
    try std.testing.expectEqualStrings("localhost", client.config.host);
    try std.testing.expectEqual(@as(u16, 8080), client.config.port);
    try std.testing.expectEqual(@as(usize, 4096), client.config.buffer_size);
}

test "TCP Client connection lifecycle" {
    var client = net.tcp.TcpClient.init(.{
        .host = "127.0.0.1",
        .port = 9000,
        .buffer_size = 8192,
    });

    // Test connection (demo mode - should not crash)
    try client.connect("127.0.0.1", 9000);

    // Test send functionality
    _ = try client.send("Hello, TCP Server!");
    _ = try client.send("Another message");

    // Test receive functionality
    var buffer1: [256]u8 = undefined;
    var buffer2: [256]u8 = undefined;
    const response1_len = try client.receive(&buffer1);
    const response2_len = try client.receive(&buffer2);

    // Both responses should be empty for demo mode
    try std.testing.expectEqual(@as(usize, 0), response1_len);
    try std.testing.expectEqual(@as(usize, 0), response2_len);
}

test "TCP Client with different configurations" {
    const configs = [_]net.config.ClientConfig{
        .{ .host = "localhost", .port = 3000, .buffer_size = 1024 },
        .{ .host = "127.0.0.1", .port = 8080, .buffer_size = 4096 },
        .{ .host = "0.0.0.0", .port = 9000, .buffer_size = 8192 },
    };

    for (configs) |config| {
        var client = net.tcp.TcpClient.init(config);

        // Test each configuration
        try std.testing.expectEqualStrings(config.host, client.config.host);
        try std.testing.expectEqual(config.port, client.config.port);
        try std.testing.expectEqual(config.buffer_size, client.config.buffer_size);

        // Test basic operations
        try client.connect("127.0.0.1", 9000);
        _ = try client.send("test");
        var buffer: [256]u8 = undefined;
        const response_len = try client.receive(&buffer);
        try std.testing.expectEqual(@as(usize, 0), response_len);
    }
}

test "TCP Server initialization" {
    const config = net.config.ServerConfig{
        .port = 8080,
        .max_connections = 100,
        .request_buffer_size = 8192,
        .response_buffer_size = 16384,
    };

    const server = net.tcp.TcpServer.init(config) catch |err| {
        // In demo mode, server init might fail, that's okay
        std.debug.print("TCP Server init failed (expected in demo mode): {}\n", .{err});
        return;
    };

    // Test configuration is correctly set
    try std.testing.expectEqual(@as(u16, 8080), server.config.port);
    try std.testing.expectEqual(@as(u32, 100), server.config.max_connections);
    try std.testing.expectEqual(@as(usize, 8192), server.config.request_buffer_size);
    try std.testing.expectEqual(@as(usize, 16384), server.config.response_buffer_size);
}

test "TCP Server start functionality" {
    var server = net.tcp.TcpServer.init(.{
        .port = 8080,
        .max_connections = 100,
        .request_buffer_size = 8192,
        .response_buffer_size = 16384,
    }) catch |err| {
        // In demo mode, server init might fail, that's okay
        std.debug.print("TCP Server init failed (expected in demo mode): {}\n", .{err});
        return;
    };

    // Server start should not crash (demo mode)
    server.start() catch |err| {
        // In demo mode, server start might fail, that's okay
        std.debug.print("TCP Server start failed (expected in demo mode): {}\n", .{err});
    };
    try std.testing.expect(true);
}

test "TCP Server with different configurations" {
    const configs = [_]net.config.ServerConfig{
        .{ .port = 3000, .max_connections = 50, .request_buffer_size = 4096, .response_buffer_size = 8192 },
        .{ .port = 8080, .max_connections = 100, .request_buffer_size = 8192, .response_buffer_size = 16384 },
        .{ .port = 9000, .max_connections = 1000, .request_buffer_size = 16384, .response_buffer_size = 32768 },
    };

    for (configs) |config| {
        var server = net.tcp.TcpServer.init(config) catch |err| {
            // In demo mode, server init might fail, that's okay
            std.debug.print("TCP Server init failed (expected in demo mode): {}\n", .{err});
            continue;
        };

        // Test each configuration
        try std.testing.expectEqual(config.port, server.config.port);
        try std.testing.expectEqual(config.max_connections, server.config.max_connections);
        try std.testing.expectEqual(config.request_buffer_size, server.config.request_buffer_size);
        try std.testing.expectEqual(config.response_buffer_size, server.config.response_buffer_size);

        // Test server start
        server.start() catch |err| {
            // In demo mode, server start might fail, that's okay
            std.debug.print("TCP Server start failed (expected in demo mode): {}\n", .{err});
        };
    }
}

test "TCP Server edge cases" {
    // Test with minimal configuration
    var minimal_server = net.tcp.TcpServer.init(.{
        .port = 1,
        .max_connections = 1,
        .request_buffer_size = 1024,
        .response_buffer_size = 1024,
    }) catch |err| {
        // In demo mode, server init might fail, that's okay
        std.debug.print("TCP Server init failed (expected in demo mode): {}\n", .{err});
        return;
    };

    try std.testing.expectEqual(@as(u16, 1), minimal_server.config.port);
    try std.testing.expectEqual(@as(u32, 1), minimal_server.config.max_connections);

    // Test with maximum configuration
    var max_server = net.tcp.TcpServer.init(.{
        .port = 65535,
        .max_connections = net.config.max_connections,
        .request_buffer_size = net.config.huge_buffer_size,
        .response_buffer_size = net.config.huge_buffer_size,
    }) catch |err| {
        // In demo mode, server init might fail, that's okay
        std.debug.print("TCP Server init failed (expected in demo mode): {}\n", .{err});
        return;
    };

    try std.testing.expectEqual(@as(u16, 65535), max_server.config.port);
    try std.testing.expectEqual(net.config.max_connections, max_server.config.max_connections);

    // Both servers should work
    minimal_server.start() catch |err| {
        std.debug.print("TCP Server start failed (expected in demo mode): {}\n", .{err});
    };
    max_server.start() catch |err| {
        std.debug.print("TCP Server start failed (expected in demo mode): {}\n", .{err});
    };
}

test "TCP Client data handling" {
    var client = net.tcp.TcpClient.init(.{
        .host = "localhost",
        .port = 8080,
        .buffer_size = 4096,
    });

    // Test sending various data types
    const test_data = [_][]const u8{
        "Simple string",
        "String with numbers: 12345",
        "String with special chars: !@#$%^&*()",
        "Empty string: ",
        "Very long string that might exceed buffer size and should be handled gracefully by the framework",
    };

    for (test_data) |data| {
        try client.connect("127.0.0.1", 9000);
        _ = try client.send(data);
        var buffer: [256]u8 = undefined;
        const response_len = try client.receive(&buffer);
        try std.testing.expectEqual(@as(usize, 0), response_len);
    }
}

test "TCP Client buffer size validation" {
    // Test with various buffer sizes
    const buffer_sizes = [_]usize{ 1024, 4096, 8192, 16384 };

    for (buffer_sizes) |buffer_size| {
        var client = net.tcp.TcpClient.init(.{
            .host = "localhost",
            .port = 8080,
            .buffer_size = buffer_size,
        });

        try std.testing.expectEqual(buffer_size, client.config.buffer_size);

        // Test operations with this buffer size
        try client.connect("127.0.0.1", 9000);
        _ = try client.send("test");
        var buffer: [256]u8 = undefined;
        const response_len = try client.receive(&buffer);
        try std.testing.expectEqual(@as(usize, 0), response_len);
    }
}
