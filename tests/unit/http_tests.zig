// Nen Net - HTTP Module Tests
// Tests HTTP server functionality and inline functions

const std = @import("std");
const net = @import("nen-net");

test "HTTP Server initialization" {
    const config = net.config.ServerConfig{
        .port = 8080,
        .max_connections = 100,
        .request_buffer_size = 8192,
        .response_buffer_size = 16384,
    };

    const server = net.http.HttpServer.init(config);

    // Test configuration is correctly set
    try std.testing.expectEqual(@as(u16, 8080), server.config.port);
    try std.testing.expectEqual(@as(u32, 100), server.config.max_connections);
    try std.testing.expectEqual(@as(usize, 8192), server.config.request_buffer_size);
    try std.testing.expectEqual(@as(usize, 16384), server.config.response_buffer_size);
}

test "HTTP Server route management" {
    var server = net.http.HttpServer.init(.{
        .port = 8080,
        .max_connections = 100,
        .request_buffer_size = 8192,
        .response_buffer_size = 16384,
    });

    // Test adding multiple routes
    try server.addRoute("GET", "/", struct {
        fn handler() void {}
    }.handler);

    try server.addRoute("POST", "/api/users", struct {
        fn handler() void {}
    }.handler);

    try server.addRoute("PUT", "/api/users/:id", struct {
        fn handler() void {}
    }.handler);

    // All routes should be added without error
    try std.testing.expect(true);
}

test "HTTP Server start functionality" {
    var server = net.http.HttpServer.init(.{
        .port = 8080,
        .max_connections = 100,
        .request_buffer_size = 8192,
        .response_buffer_size = 16384,
    });

    // Server start should not crash (demo mode)
    try server.start();
    try std.testing.expect(true);
}

test "HTTP Request structure" {
    const headers = [_]net.http.HttpRequest.Header{
        .{ .name = "Content-Type", .value = "application/json" },
        .{ .name = "Authorization", .value = "Bearer token123" },
    };

    const request = net.http.HttpRequest{
        .method = "POST",
        .path = "/api/users",
        .headers = &headers,
        .body = "{\"name\":\"John\",\"email\":\"john@example.com\"}",
    };

    // Test request structure
    try std.testing.expectEqualStrings("POST", request.method);
    try std.testing.expectEqualStrings("/api/users", request.path);
    try std.testing.expectEqual(@as(usize, 2), request.headers.len);
    try std.testing.expectEqualStrings("application/json", request.headers[0].value);
    try std.testing.expectEqualStrings("Bearer token123", request.headers[1].value);
    try std.testing.expectEqualStrings("{\"name\":\"John\",\"email\":\"john@example.com\"}", request.body);
}

test "HTTP Response structure" {
    const headers = [_]net.http.HttpResponse.Header{
        .{ .name = "Content-Type", .value = "application/json" },
        .{ .name = "Cache-Control", .value = "no-cache" },
    };

    const response = net.http.HttpResponse{
        .status_code = 201,
        .body = "{\"id\":123,\"status\":\"created\"}",
        .headers = &headers,
    };

    // Test response structure
    try std.testing.expectEqual(@as(u16, 201), response.status_code);
    try std.testing.expectEqualStrings("{\"id\":123,\"status\":\"created\"}", response.body);
    try std.testing.expectEqual(@as(usize, 2), response.headers.len);
    try std.testing.expectEqualStrings("application/json", response.headers[0].value);
    try std.testing.expectEqualStrings("no-cache", response.headers[1].value);
}

test "HTTP Server with different configurations" {
    const configs = [_]net.config.ServerConfig{
        .{ .port = 3000, .max_connections = 50, .request_buffer_size = 4096, .response_buffer_size = 8192 },
        .{ .port = 8080, .max_connections = 100, .request_buffer_size = 8192, .response_buffer_size = 16384 },
        .{ .port = 9000, .max_connections = 1000, .request_buffer_size = 16384, .response_buffer_size = 32768 },
    };

    for (configs) |config| {
        var server = net.http.HttpServer.init(config);

        // Test each configuration
        try std.testing.expectEqual(config.port, server.config.port);
        try std.testing.expectEqual(config.max_connections, server.config.max_connections);
        try std.testing.expectEqual(config.request_buffer_size, server.config.request_buffer_size);
        try std.testing.expectEqual(config.response_buffer_size, server.config.response_buffer_size);

        // Test route addition
        try server.addRoute("GET", "/test", struct {
            fn handler() void {}
        }.handler);

        // Test server start
        try server.start();
    }
}

test "HTTP Server edge cases" {
    // Test with minimal configuration
    var minimal_server = net.http.HttpServer.init(.{
        .port = 1,
        .max_connections = 1,
        .request_buffer_size = 1024,
        .response_buffer_size = 1024,
    });

    try std.testing.expectEqual(@as(u16, 1), minimal_server.config.port);
    try std.testing.expectEqual(@as(u32, 1), minimal_server.config.max_connections);

    // Test with maximum configuration
    var max_server = net.http.HttpServer.init(.{
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
