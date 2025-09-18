// Nen Net - Advanced Router Example
// Demonstrates the comprehensive router system with path parameters, middleware, and groups

const std = @import("std");
const nen_net = @import("nen-net");
const routing = nen_net.routing;
const http = nen_net.http;

// Example handlers
fn indexHandler(req: *http.HttpRequest, res: *http.HttpResponse) void {
    res.html(
        \\<!DOCTYPE html>
        \\<html>
        \\<head><title>Nen Net Router Example</title></head>
        \\<body>
        \\<h1>Nen Net Advanced Router</h1>
        \\<ul>
        \\<li><a href="/hello">Hello World</a></li>
        \\<li><a href="/api/users/123">User 123</a></li>
        \\<li><a href="/api/posts/456">Post 456</a></li>
        \\<li><a href="/search?q=zig&page=1">Search</a></li>
        \\<li><a href="/admin/users">Admin Users</a></li>
        \\</ul>
        \\</body>
        \\</html>
    );
}

fn helloHandler(req: *http.HttpRequest, res: *http.HttpResponse) void {
    res.text("Hello from Nen Net!");
}

fn userHandler(req: *http.HttpRequest, res: *http.HttpResponse) void {
    const user_id = req.param("id").?;
    try res.json(.{
        .user_id = user_id,
        .name = "User " ++ user_id,
        .email = "user" ++ user_id ++ "@example.com",
    });
}

fn postHandler(req: *http.HttpRequest, res: *http.HttpResponse) void {
    const post_id = req.param("id").?;
    try res.json(.{
        .post_id = post_id,
        .title = "Post " ++ post_id,
        .content = "This is the content of post " ++ post_id,
    });
}

fn searchHandler(req: *http.HttpRequest, res: *http.HttpResponse) void {
    const query = req.getQueryParam("q") catch null;
    const page = req.getQueryParam("page") catch null;

    try res.json(.{
        .query = query orelse "",
        .page = page orelse "1",
        .results = [_]string{ "Result 1", "Result 2", "Result 3" },
    });
}

fn adminUserHandler(req: *http.HttpRequest, res: *http.HttpResponse) void {
    try res.json(.{
        .message = "Admin users endpoint",
        .users = [_]string{ "admin1", "admin2", "admin3" },
    });
}

// Middleware examples
fn loggingMiddleware(req: *http.HttpRequest, res: *http.HttpResponse, executor: *routing.MiddlewareExecutor) void {
    std.debug.print("Request: {} {s}\n", .{ req.method, req.path });
    executor.next();
}

fn authMiddleware(req: *http.HttpRequest, res: *http.HttpResponse, executor: *routing.MiddlewareExecutor) void {
    const auth_header = req.getHeader("authorization");
    if (auth_header == null) {
        res.setStatus(.UNAUTHORIZED);
        res.text("Unauthorized");
        return;
    }
    executor.next();
}

fn corsMiddleware(req: *http.HttpRequest, res: *http.HttpResponse, executor: *routing.MiddlewareExecutor) void {
    res.addHeader("Access-Control-Allow-Origin", "*") catch {};
    res.addHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE") catch {};
    res.addHeader("Access-Control-Allow-Headers", "Content-Type, Authorization") catch {};
    executor.next();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Create HTTP server
    var server = try http.HttpServer.init(.{
        .port = 8080,
        .max_connections = 1000,
        .request_buffer_size = 4096,
        .response_buffer_size = 8192,
    });

    // Create router
    var router = routing.Router.init();

    // Add global middleware
    try router.addMiddleware(loggingMiddleware);
    try router.addMiddleware(corsMiddleware);

    // Add routes
    try router.get("/", indexHandler);
    try router.get("/hello", helloHandler);
    try router.get("/api/users/:id", userHandler);
    try router.get("/api/posts/:id", postHandler);
    try router.get("/search", searchHandler);

    // Create admin route group with auth middleware
    var admin_routes: [10]routing.Route = undefined;
    var admin_group = routing.RouteGroup.init("/admin", .{
        .middlewares = &.{authMiddleware},
    }, &admin_routes);

    try admin_group.addRoute(.GET, "/users", adminUserHandler);

    // Add admin routes to main router
    for (0..admin_group.route_count) |i| {
        try router.addRouteWithConfig(admin_group.routes[i].method, admin_group.routes[i].path, admin_group.routes[i].handler, admin_group.routes[i].config);
    }

    // Set router on server
    server.setRouter(&router);

    // Start server
    std.debug.print("Starting Nen Net server on port 8080...\n");
    try server.start();

    // Keep server running
    while (server.isRunning()) {
        std.time.sleep(std.time.ns_per_ms * 100);
    }
}
