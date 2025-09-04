// Nen Net - HTTP Server Example
// Demonstrates a real HTTP server with static allocation

const std = @import("std");
const net = @import("nen-net");

// Example route handlers
fn handleRoot(request: *net.HttpRequest, response: *net.HttpResponse) void {
    _ = request; // Suppress unused parameter warning

    response.status_code = .OK;
    response.setBody("Hello from Nen Net HTTP Server!");
    response.addHeader("Content-Type", "text/plain") catch {};
}

fn handleHealth(request: *net.HttpRequest, response: *net.HttpResponse) void {
    _ = request; // Suppress unused parameter warning

    response.status_code = .OK;
    response.setBody("{\"status\":\"healthy\",\"timestamp\":\"2024-01-01T00:00:00Z\"}");
    response.addHeader("Content-Type", "application/json") catch {};
}

fn handleEcho(request: *net.HttpRequest, response: *net.HttpResponse) void {
    response.status_code = .OK;
    response.setBody(request.body);
    response.addHeader("Content-Type", "text/plain") catch {};
}

fn handleNotFound(request: *net.HttpRequest, response: *net.HttpResponse) void {
    _ = request; // Suppress unused parameter warning

    response.status_code = .NOT_FOUND;
    response.setBody("404 - Not Found");
    response.addHeader("Content-Type", "text/plain") catch {};
}

pub fn main() !void {
    std.debug.print("🚀 Nen Net HTTP Server Example\n", .{});
    std.debug.print("===============================\n\n", .{});

    // Create HTTP server with static configuration
    var server = try net.HttpServer.init(.{
        .port = 8080,
        .max_connections = 100,
        .request_buffer_size = 8192,
        .response_buffer_size = 16384,
    });

    std.debug.print("✅ HTTP server created on port 8080\n", .{});
    std.debug.print("📊 Server configuration:\n", .{});
    std.debug.print("   • Port: {d}\n", .{server.config.port});
    std.debug.print("   • Max connections: {d}\n", .{server.config.max_connections});
    std.debug.print("   • Request buffer: {d} bytes\n", .{server.config.request_buffer_size});
    std.debug.print("   • Response buffer: {d} bytes\n", .{server.config.response_buffer_size});

    // Add routes
    try server.addRoute(.GET, "/", handleRoot);
    try server.addRoute(.GET, "/health", handleHealth);
    try server.addRoute(.POST, "/echo", handleEcho);

    std.debug.print("✅ Added 3 routes:\n", .{});
    std.debug.print("   • GET  /      → Root handler\n", .{});
    std.debug.print("   • GET  /health → Health check\n", .{});
    std.debug.print("   • POST /echo   → Echo handler\n", .{});

    // Test route finding
    const root_handler = server.findRoute(.GET, "/");
    const health_handler = server.findRoute(.GET, "/health");
    const echo_handler = server.findRoute(.POST, "/echo");
    const not_found_handler = server.findRoute(.GET, "/nonexistent");

    std.debug.print("\n🔍 Route testing:\n", .{});
    std.debug.print("   • GET /: {}\n", .{root_handler != null});
    std.debug.print("   • GET /health: {}\n", .{health_handler != null});
    std.debug.print("   • POST /echo: {}\n", .{echo_handler != null});
    std.debug.print("   • GET /nonexistent: {}\n", .{not_found_handler != null});

    // Test HTTP parsing
    std.debug.print("\n🔧 HTTP parsing tests:\n", .{});

    // Test method parsing
    const get_method = net.HttpParser.parseMethod("GET");
    const post_method = net.HttpParser.parseMethod("POST");
    const invalid_method = net.HttpParser.parseMethod("INVALID");

    std.debug.print("   • GET method: {}\n", .{get_method == .GET});
    std.debug.print("   • POST method: {}\n", .{post_method == .POST});
    std.debug.print("   • Invalid method: {}\n", .{invalid_method == null});

    // Test request line parsing
    const request_line = "GET /api/users HTTP/1.1";
    const parsed = net.HttpParser.parseRequestLine(request_line);

    if (parsed) |req| {
        std.debug.print("   • Request line parsing: {} {s} {s}\n", .{ req[0], req[1], req[2] });
    } else {
        std.debug.print("   • Request line parsing: FAILED\n", .{});
    }

    // Test response formatting
    var response = net.HttpResponse{
        .status_code = .OK,
        .body = "Hello, World!",
    };
    try response.addHeader("Content-Type", "text/plain");

    var response_buffer: [1024]u8 = undefined;
    const formatted_response = try net.HttpParser.formatResponse(&response, &response_buffer);

    std.debug.print("   • Response formatting: {} bytes\n", .{formatted_response.len});
    const preview_len = @min(50, formatted_response.len);
    std.debug.print("   • Response preview: {s}\n", .{formatted_response[0..preview_len]});

    // Start server (demo mode - would actually listen in production)
    try server.start();
    std.debug.print("\n🎯 Server started successfully!\n", .{});
    std.debug.print("💡 In production, the server would now listen for HTTP requests\n", .{});
    std.debug.print("💡 All networking operations use static allocation for predictable performance\n", .{});

    // Clean shutdown
    server.stop();
    std.debug.print("🛑 Server stopped\n", .{});
}
