// Nen Net - HTTP Server Demo
// Demonstrates creating a simple HTTP server with static allocation

const std = @import("std");
const net = @import("../src/lib.zig");

pub fn main() !void {
    std.debug.print("🚀 Nen Net HTTP Server Demo\n", .{});
    std.debug.print("============================\n\n", .{});

    // Create HTTP server with static configuration
    var server = try net.createHttpServer(8080);
    
    std.debug.print("✅ HTTP server created on port 8080\n", .{});
    std.debug.print("📊 Server configuration:\n", .{});
    std.debug.print("   • Max connections: {d}\n", .{net.max_connections});
    std.debug.print("   • Request buffer: {d} bytes\n", .{net.request_buffer_size});
    std.debug.print("   • Response buffer: {d} bytes\n", .{net.response_buffer_size});
    
    // Add routes
    try server.addRoute(.GET, "/", handleRoot);
    try server.addRoute(.GET, "/health", handleHealth);
    try server.addRoute(.POST, "/echo", handleEcho);
    
    std.debug.print("✅ Added 3 routes:\n", .{});
    std.debug.print("   • GET  /      → Root handler\n", .{});
    std.debug.print("   • GET  /health → Health check\n", .{});
    std.debug.print("   • POST /echo   → Echo handler\n", .{});
    
    std.debug.print("\n🎯 Server is ready!\n", .{});
    std.debug.print("💡 This is a demo - the server would start listening in production\n", .{});
}

fn handleRoot(request: net.http.HttpRequest) !net.http.HttpResponse {
    _ = request;
    return net.http.HttpResponse{
        .status_code = 200,
        .body = "Hello from Nen Net! 🚀\n\nThis is a statically allocated HTTP server.",
        .headers = &.{},
    };
}

fn handleHealth(request: net.http.HttpRequest) !net.http.HttpResponse {
    _ = request;
    return net.http.HttpResponse{
        .status_code = 200,
        .body = "{\"status\":\"healthy\",\"framework\":\"nen-net\",\"timestamp\":\"2024-08-28\"}",
        .headers = &.{.{ .name = "Content-Type", .value = "application/json" }},
    };
}

fn handleEcho(request: net.http.HttpRequest) !net.http.HttpResponse {
    return net.http.HttpResponse{
        .status_code = 200,
        .body = request.body,
        .headers = &.{.{ .name = "Content-Type", .value = "text/plain" }},
    };
}
