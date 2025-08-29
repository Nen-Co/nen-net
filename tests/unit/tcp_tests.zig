// Nen Net - TCP Module Tests
// Tests TCP client/server functionality and inline functions

const std = @import("std");
const net = @import("../../src/lib.zig");

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
    const client = net.tcp.TcpClient.init(.{
        .host = "127.0.0.1",
        .port = 9000,
        .buffer_size = 8192,
    });

    // Test connection (demo mode - should not crash)
    try client.connect();
    
    // Test send functionality
    try client.send("Hello, TCP Server!");
    try client.send("Another message");
    
    // Test receive functionality
    const response1 = try client.receive();
    const response2 = try client.receive();
    
    // Both responses should be the demo response
    try std.testing.expectEqualStrings("demo response", response1);
    try std.testing.expectEqualStrings("demo response", response2);
}

test "TCP Client with different configurations" {
    const configs = [_]net.config.ClientConfig{
        .{ .host = "localhost", .port = 3000, .buffer_size = 1024 },
        .{ .host = "127.0.0.1", .port = 8080, .buffer_size = 4096 },
        .{ .host = "0.0.0.0", .port = 9000, .buffer_size = 8192 },
    };

    for (configs) |config| {
        const client = net.tcp.TcpClient.init(config);
        
        // Test each configuration
        try std.testing.expectEqualStrings(config.host, client.config.host);
        try std.testing.expectEqual(config.port, client.config.port);
        try std.testing.expectEqual(config.buffer_size, client.config.buffer_size);
        
        // Test basic operations
        try client.connect();
        try client.send("test");
        const response = try client.receive();
        try std.testing.expectEqualStrings("demo response", response);
    }
}

test "TCP Server initialization" {
    const config = net.config.ServerConfig{
        .port = 8080,
        .max_connections = 100,
        .request_buffer_size = 8192,
        .response_buffer_size = 16384,
    };

    const server = net.tcp.TcpServer.init(config);
    
    // Test configuration is correctly set
    try std.testing.expectEqual(@as(u16, 8080), server.config.port);
    try std.testing.expectEqual(@as(u32, 100), server.config.max_connections);
    try std.testing.expectEqual(@as(usize, 8192), server.config.request_buffer_size);
    try std.testing.expectEqual(@as(usize, 16384), server.config.response_buffer_size);
}

test "TCP Server start functionality" {
    const server = net.tcp.TcpServer.init(.{
        .port = 8080,
        .max_connections = 100,
        .request_buffer_size = 8192,
        .response_buffer_size = 16384,
    });

    // Server start should not crash (demo mode)
    try server.start();
    try std.testing.expect(true);
}

test "TCP Server with different configurations" {
    const configs = [_]net.config.ServerConfig{
        .{ .port = 3000, .max_connections = 50, .request_buffer_size = 4096, .response_buffer_size = 8192 },
        .{ .port = 8080, .max_connections = 100, .request_buffer_size = 8192, .response_buffer_size = 16384 },
        .{ .port = 9000, .max_connections = 1000, .request_buffer_size = 16384, .response_buffer_size = 32768 },
    };

    for (configs) |config| {
        const server = net.tcp.TcpServer.init(config);
        
        // Test each configuration
        try std.testing.expectEqual(config.port, server.config.port);
        try std.testing.expectEqual(config.max_connections, server.config.max_connections);
        try std.testing.expectEqual(config.request_buffer_size, server.config.request_buffer_size);
        try std.testing.expectEqual(config.response_buffer_size, server.config.response_buffer_size);
        
        // Test server start
        try server.start();
    }
}

test "TCP Server edge cases" {
    // Test with minimal configuration
    var minimal_server = net.tcp.TcpServer.init(.{
        .port = 1,
        .max_connections = 1,
        .request_buffer_size = 1024,
        .response_buffer_size = 1024,
    });
    
    try std.testing.expectEqual(@as(u16, 1), minimal_server.config.port);
    try std.testing.expectEqual(@as(u32, 1), minimal_server.config.max_connections);
    
    // Test with maximum configuration
    var max_server = net.tcp.TcpServer.init(.{
        .port = 65535,
        .max_connections = net.config.max_connections,
        .request_buffer_size = net.config.huge_buffer_size,
        .response_buffer_size = net.config.huge_buffer_size,
    });
    
    try std.testing.expectEqual(@as(u16, 65535), max_server.config.port);
    try std.testing.expectEqual(net.config.max_connections, max_server.config.max_connections);
    
    // Both servers should work
    try minimal_server.start();
    try max_server.start();
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
        try client.connect();
        try client.send(data);
        const response = try client.receive();
        try std.testing.expectEqualStrings("demo response", response);
    }
}

test "TCP Client buffer size validation" {
    // Test with various buffer sizes
    const buffer_sizes = [_]usize{ 1024, 4096, 8192, 16384 };
    
    for (buffer_sizes) |buffer_size| {
        const client = net.tcp.TcpClient.init(.{
            .host = "localhost",
            .port = 8080,
            .buffer_size = buffer_size,
        });
        
        try std.testing.expectEqual(buffer_size, client.config.buffer_size);
        
        // Test operations with this buffer size
        try client.connect();
        try client.send("test");
        const response = try client.receive();
        try std.testing.expectEqualStrings("demo response", response);
    }
}
