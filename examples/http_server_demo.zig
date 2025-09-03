// Nen Net - HTTP Server Demo
// Demonstrates creating a simple HTTP server with static allocation

const std = @import("std");
const net = @import("nen-net");

pub fn main() !void {
    std.debug.print("🚀 Nen Net HTTP Server Demo\n", .{});
    std.debug.print("============================\n\n", .{});

    // Create HTTP server with static configuration
    var server = net.http.HttpServer.init(.{
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
    try server.addRoute("GET", "/", handleRoot);
    try server.addRoute("GET", "/health", handleHealth);
    try server.addRoute("POST", "/echo", handleEcho);

    std.debug.print("✅ Added 3 routes:\n", .{});
    std.debug.print("   • GET  /      → Root handler\n", .{});
    std.debug.print("   • GET  /health → Health check\n", .{});
    std.debug.print("   • POST /echo   → Echo handler\n", .{});

    // Start server (demo mode)
    try server.start();

    std.debug.print("\n🎯 Server is ready!\n", .{});
    std.debug.print("💡 This is a demo - the server would start listening in production\n", .{});
}

fn handleRoot() void {
    std.debug.print("📝 Root handler called\n", .{});
}

fn handleHealth() void {
    std.debug.print("🏥 Health check handler called\n", .{});
}

fn handleEcho() void {
    std.debug.print("🔄 Echo handler called\n", .{});
}