// Nen Net - WebSocket Module Tests
// Tests WebSocket server functionality and inline functions

const std = @import("std");
const net = @import("../../src/lib.zig");

test "WebSocket Server initialization" {
    const config = net.config.WebSocketConfig{
        .port = 8080,
        .max_connections = 100,
    };

    var ws_server = net.websocket.WebSocketServer.init(config);
    
    // Test configuration is correctly set
    try std.testing.expectEqual(@as(u16, 8080), ws_server.config.port);
    try std.testing.expectEqual(@as(u32, 100), ws_server.config.max_connections);
}

test "WebSocket Server handler setup" {
    var ws_server = net.websocket.WebSocketServer.init(.{
        .port = 8080,
        .max_connections = 100,
    });

    // Test setting up connection handler
    try ws_server.onConnect(struct {
        fn handler() void {
            // This would handle new WebSocket connections
        }
    }.handler);

    // Test setting up message handler
    try ws_server.onMessage(struct {
        fn handler() void {
            // This would handle incoming WebSocket messages
        }
    }.handler);

    // Both handlers should be set without error
    try std.testing.expect(true);
}

test "WebSocket Server start functionality" {
    var ws_server = net.websocket.WebSocketServer.init(.{
        .port = 8080,
        .max_connections = 100,
    });

    // Server start should not crash (demo mode)
    try ws_server.start();
    try std.testing.expect(true);
}

test "WebSocket Server with different configurations" {
    const configs = [_]net.config.WebSocketConfig{
        .{ .port = 3000, .max_connections = 50 },
        .{ .port = 8080, .max_connections = 100 },
        .{ .port = 9000, .max_connections = 1000 },
    };

    for (configs) |config| {
        var ws_server = net.websocket.WebSocketServer.init(config);
        
        // Test each configuration
        try std.testing.expectEqual(config.port, ws_server.config.port);
        try std.testing.expectEqual(config.max_connections, ws_server.config.max_connections);
        
        // Test handler setup
        try ws_server.onConnect(struct {
            fn handler() void {}
        }.handler);
        
        try ws_server.onMessage(struct {
            fn handler() void {}
        }.handler);
        
        // Test server start
        try ws_server.start();
    }
}

test "WebSocket Server edge cases" {
    // Test with minimal configuration
    var minimal_ws = net.websocket.WebSocketServer.init(.{
        .port = 1,
        .max_connections = 1,
    });
    
    try std.testing.expectEqual(@as(u16, 1), minimal_ws.config.port);
    try std.testing.expectEqual(@as(u32, 1), minimal_ws.config.max_connections);
    
    // Test with maximum configuration
    var max_ws = net.websocket.WebSocketServer.init(.{
        .port = 65535,
        .max_connections = net.config.max_connections,
    });
    
    try std.testing.expectEqual(@as(u16, 65535), max_ws.config.port);
    try std.testing.expectEqual(net.config.max_connections, max_ws.config.max_connections);
    
    // Both servers should work
    try minimal_ws.start();
    try max_ws.start();
}

test "WebSocket Server multiple handlers" {
    var ws_server = net.websocket.WebSocketServer.init(.{
        .port = 8080,
        .max_connections = 100,
    });

    // Test setting multiple handlers of the same type
    try ws_server.onConnect(struct {
        fn handler() void {}
    }.handler);

    try ws_server.onConnect(struct {
        fn handler() void {}
    }.handler);

    try ws_server.onMessage(struct {
        fn handler() void {}
    }.handler);

    try ws_server.onMessage(struct {
        fn handler() void {}
    }.handler);

    // All handlers should be set without error
    try std.testing.expect(true);
    
    // Test server start
    try ws_server.start();
}

test "WebSocket Server configuration validation" {
    // Test that configuration values are reasonable
    const config = net.config.WebSocketConfig{
        .port = 8080,
        .max_connections = 100,
    };

    try std.testing.expect(config.port > 0 and config.port <= 65535);
    try std.testing.expect(config.max_connections > 0 and config.max_connections <= net.config.max_connections);
}

test "WebSocket Server lifecycle" {
    var ws_server = net.websocket.WebSocketServer.init(.{
        .port = 8080,
        .max_connections = 100,
    });

    // Test complete lifecycle
    try ws_server.onConnect(struct {
        fn handler() void {}
    }.handler);

    try ws_server.onMessage(struct {
        fn handler() void {}
    }.handler);

    try ws_server.start();
    
    // All operations should complete successfully
    try std.testing.expect(true);
}

test "WebSocket Server with various ports" {
    const ports = [_]u16{ 3000, 8080, 9000, 12345, 54321 };
    
    for (ports) |port| {
        var ws_server = net.websocket.WebSocketServer.init(.{
            .port = port,
            .max_connections = 100,
        });
        
        try std.testing.expectEqual(port, ws_server.config.port);
        
        // Test basic functionality
        try ws_server.onConnect(struct {
            fn handler() void {}
        }.handler);
        
        try ws_server.start();
    }
}
