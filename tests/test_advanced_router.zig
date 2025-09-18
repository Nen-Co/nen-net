// Nen Net - Advanced Router Tests
// Comprehensive tests for the new router system

const std = @import("std");
const testing = std.testing;
const nen_net = @import("nen-net");
const routing = nen_net.routing;
const http = nen_net.http;

// Test handlers
fn testHandler(req: *http.HttpRequest, res: *http.HttpResponse) void {
    res.text("test response");
}

fn jsonHandler(req: *http.HttpRequest, res: *http.HttpResponse) void {
    try res.json(.{ .message = "json response" });
}

fn paramHandler(req: *http.HttpRequest, res: *http.HttpResponse) void {
    const id = req.param("id").?;
    try res.json(.{ .id = id });
}

fn queryHandler(req: *http.HttpRequest, res: *http.HttpResponse) void {
    const query = req.getQueryParam("q") catch null;
    try res.json(.{ .query = query orelse "" });
}

// Test middleware
fn testMiddleware(req: *http.HttpRequest, res: *http.HttpResponse, executor: *routing.MiddlewareExecutor) void {
    res.addHeader("X-Test-Middleware", "true") catch {};
    executor.next();
}

test "router basic functionality" {
    var router = routing.Router.init();

    // Test adding routes
    try router.get("/test", testHandler);
    try router.post("/api/test", jsonHandler);

    // Test route finding
    var params: [8]routing.PathParam = undefined;
    const match = router.findRoute(.GET, "/test", &params);
    try testing.expect(match != null);

    const post_match = router.findRoute(.POST, "/api/test", &params);
    try testing.expect(post_match != null);
}

test "path parameters" {
    var router = routing.Router.init();
    try router.get("/users/:id", paramHandler);

    var params: [8]routing.PathParam = undefined;
    const match = router.findRoute(.GET, "/users/123", &params);
    try testing.expect(match != null);
    try testing.expectEqual(@as(u8, 1), match.?.param_count);
    try testing.expectEqualStrings("id", params[0].name);
    try testing.expectEqualStrings("123", params[0].value);
}

test "query parameters" {
    var req = http.HttpRequest{
        .method = .GET,
        .path = "/search",
        .query_string = "q=zig&page=1",
    };

    const query = try req.query();
    try testing.expectEqual(@as(u8, 2), query.len);
    try testing.expectEqualStrings("q", query[0].name);
    try testing.expectEqualStrings("zig", query[0].value);
    try testing.expectEqualStrings("page", query[1].name);
    try testing.expectEqualStrings("1", query[1].value);
}

test "query parameter lookup" {
    var req = http.HttpRequest{
        .method = .GET,
        .path = "/search",
        .query_string = "q=zig&page=1",
    };

    const query = try req.getQueryParam("q");
    try testing.expect(query != null);
    try testing.expectEqualStrings("zig", query.?);

    const missing = try req.getQueryParam("missing");
    try testing.expect(missing == null);
}

test "middleware execution" {
    var router = routing.Router.init();
    try router.addMiddleware(testMiddleware);
    try router.get("/middleware-test", testHandler);

    var req = http.HttpRequest{
        .method = .GET,
        .path = "/middleware-test",
    };
    var res = http.HttpResponse{
        .status_code = .OK,
    };

    var params: [8]routing.PathParam = undefined;
    const match = router.findRoute(.GET, "/middleware-test", &params);
    try testing.expect(match != null);

    // Execute route with middleware
    router.executeRoute(match.?.route, &req, &res, match.?.param_count);

    // Check if middleware header was added
    const header = res.getHeader("X-Test-Middleware");
    try testing.expect(header != null);
    try testing.expectEqualStrings("true", header.?);
}

test "route groups" {
    var admin_routes: [10]routing.Route = undefined;
    var admin_group = routing.RouteGroup.init("/admin", .{}, &admin_routes);

    try admin_group.addRoute(.GET, "/users", testHandler);
    try admin_group.addRoute(.POST, "/posts", jsonHandler);

    try testing.expectEqual(@as(u8, 2), admin_group.route_count);
    try testing.expectEqualStrings("/admin/users", admin_group.routes[0].path);
    try testing.expectEqualStrings("/admin/posts", admin_group.routes[1].path);
}

test "HTTP method parsing" {
    try testing.expectEqual(routing.HttpMethod.GET, routing.HttpMethod.fromString("GET").?);
    try testing.expectEqual(routing.HttpMethod.POST, routing.HttpMethod.fromString("POST").?);
    try testing.expectEqual(routing.HttpMethod.PUT, routing.HttpMethod.fromString("PUT").?);
    try testing.expectEqual(routing.HttpMethod.DELETE, routing.HttpMethod.fromString("DELETE").?);
    try testing.expectEqual(routing.HttpMethod.HEAD, routing.HttpMethod.fromString("HEAD").?);
    try testing.expectEqual(routing.HttpMethod.OPTIONS, routing.HttpMethod.fromString("OPTIONS").?);
    try testing.expectEqual(routing.HttpMethod.PATCH, routing.HttpMethod.fromString("PATCH").?);
    try testing.expectEqual(routing.HttpMethod.OTHER, routing.HttpMethod.fromString("CUSTOM").?);
}

test "content type helpers" {
    var res = http.HttpResponse{
        .status_code = .OK,
    };

    // Test JSON response
    try res.json(.{ .message = "test" });
    try testing.expectEqual(http.ContentType.JSON, res.content_type);

    // Test text response
    res.text("hello world");
    try testing.expectEqual(http.ContentType.TEXT, res.content_type);

    // Test HTML response
    res.html("<h1>Hello</h1>");
    try testing.expectEqual(http.ContentType.HTML, res.content_type);
}

test "response writer" {
    var res = http.HttpResponse{
        .status_code = .OK,
    };

    var writer = res.writer();
    try writer.print("Hello {s}", .{"World"});
    try writer.writeAll("!");
    writer.flush();

    try testing.expectEqualStrings("Hello World!", res.body);
}

test "route specificity" {
    var router = routing.Router.init();

    // Add more specific route first
    try router.get("/api/users/:id", paramHandler);
    // Add less specific route
    try router.get("/api/*", testHandler);

    var params: [8]routing.PathParam = undefined;
    const match = router.findRoute(.GET, "/api/users/123", &params);
    try testing.expect(match != null);

    // Should match the more specific route
    try testing.expectEqualStrings("/api/users/:id", match.?.route.path);
}

test "glob patterns" {
    var router = routing.Router.init();
    try router.get("/*", testHandler);

    var params: [8]routing.PathParam = undefined;
    const match = router.findRoute(.GET, "/any/path/here", &params);
    try testing.expect(match != null);
    try testing.expectEqualStrings("/*", match.?.route.path);
}

test "error handling" {
    var router = routing.Router.init();

    // Test too many routes
    var i: u8 = 0;
    while (i < 130) : (i += 1) {
        const result = router.get("/test", testHandler);
        if (i >= 128) {
            try testing.expectError(routing.RouterError.TooManyRoutes, result);
        }
    }

    // Test too many middlewares
    var j: u8 = 0;
    while (j < 20) : (j += 1) {
        const result = router.addMiddleware(testMiddleware);
        if (j >= 16) {
            try testing.expectError(routing.RouterError.TooManyMiddlewares, result);
        }
    }
}
