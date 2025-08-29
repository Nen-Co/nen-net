// Nen Net - Main Executable
// Demonstrates the statically allocated HTTP and TCP framework

const std = @import("std");
const net = @import("lib.zig");

pub fn main() !void {
    std.debug.print("🚀 Nen Net - Static HTTP & TCP Framework\n", .{});
    std.debug.print("=========================================\n\n", .{});

    // Example 1: HTTP Server Demo
    try httpServerDemo();
    
    // Example 2: TCP Client Demo
    try tcpClientDemo();
    
    // Example 3: Performance Demo
    try performanceDemo();
    
    std.debug.print("\n🎉 All demos completed successfully!\n", .{});
    std.debug.print("\n💡 Key Features:\n", .{});
    std.debug.print("   • Zero dynamic allocation\n", .{});
    std.debug.print("   • Static connection pools\n", .{});
    std.debug.print("   • High-performance networking\n", .{});
    std.debug.print("   • Built-in performance monitoring\n", .{});
}

fn httpServerDemo() !void {
    std.debug.print("🌐 Example 1: HTTP Server Demo\n", .{});
    
    // Create HTTP server with static configuration
    var server = try net.createHttpServer(8080);
    
    std.debug.print("  ✅ HTTP server created on port 8080\n", .{});
    std.debug.print("  📊 Configuration:\n", .{});
    std.debug.print("     • Max connections: {d}\n", .{net.max_connections});
    std.debug.print("     • Request buffer: {d} bytes\n", .{net.request_buffer_size});
    std.debug.print("     • Response buffer: {d} bytes\n", .{net.response_buffer_size});
    
    // Add some example routes
    try server.addRoute("GET", "/", handleRoot);
    try server.addRoute("GET", "/api/status", handleStatus);
    try server.addRoute("POST", "/api/data", handleData);
    
    std.debug.print("  ✅ Added 3 example routes\n", .{});
    std.debug.print("  🚀 Server ready to start (demo mode)\n\n", .{});
}

fn tcpClientDemo() !void {
    std.debug.print("🔌 Example 2: TCP Client Demo\n", .{});
    
    // Create TCP client with static configuration
    _ = try net.createTcpClient("localhost", 8080);
    
    std.debug.print("  ✅ TCP client created\n", .{});
    std.debug.print("  📊 Configuration:\n", .{});
    std.debug.print("     • Host: localhost\n", .{});
    std.debug.print("     • Port: 8080\n", .{});
    std.debug.print("     • Buffer size: {d} bytes\n", .{net.client_buffer_size});
    
    std.debug.print("  🔗 Client ready to connect (demo mode)\n\n", .{});
}

fn performanceDemo() !void {
    std.debug.print("⚡ Example 3: Performance Demo\n", .{});
    
    // Start performance monitoring
    _ = try net.startPerformanceMonitoring();
    
    std.debug.print("  ✅ Performance monitoring started\n", .{});
    std.debug.print("  📊 Performance Targets:\n", .{});
    std.debug.print("     • Max connections: {d}\n", .{net.PERFORMANCE_TARGETS.max_concurrent_connections});
    std.debug.print("     • Requests/sec: {d}\n", .{net.PERFORMANCE_TARGETS.requests_per_second});
    std.debug.print("     • Max latency: {d}ms\n", .{net.PERFORMANCE_TARGETS.max_latency_ms});
    std.debug.print("     • Memory overhead: <{d}%\n", .{net.PERFORMANCE_TARGETS.memory_overhead_percent});
    std.debug.print("     • Startup time: <{d}ms\n", .{net.PERFORMANCE_TARGETS.startup_time_ms});
    
    std.debug.print("  🎯 Performance monitoring active (demo mode)\n\n", .{});
}

// Example route handlers (demo mode)
fn handleRoot(request: net.http.HttpRequest) !net.http.HttpResponse {
    _ = request;
    return net.http.HttpResponse{
        .status_code = 200,
        .body = "Hello from Nen Net! 🚀",
        .headers = &.{},
    };
}

fn handleStatus(request: net.http.HttpRequest) !net.http.HttpResponse {
    _ = request;
    return net.http.HttpResponse{
        .status_code = 200,
        .body = "{\"status\":\"running\",\"framework\":\"nen-net\"}",
        .headers = &.{.{ .name = "Content-Type", .value = "application/json" }},
    };
}

fn handleData(request: net.http.HttpRequest) !net.http.HttpResponse {
    return net.http.HttpResponse{
        .status_code = 201,
        .body = request.body,
        .headers = &.{.{ .name = "Content-Type", .value = "text/plain" }},
    };
}
