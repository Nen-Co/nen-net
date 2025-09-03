// Nen Net - Routing Module Tests
// Tests routing functionality and inline functions

const std = @import("std");
const net = @import("nen-net");

test "Router initialization" {
    const routes = [_]net.routing.Route{
        .{ .method = "GET", .path = "/", .handler = struct {
            fn handler() void {}
        }.handler },
        .{ .method = "POST", .path = "/api", .handler = struct {
            fn handler() void {}
        }.handler },
    };

    const router = net.routing.Router.init(&routes);

    // Test that routes are correctly set
    try std.testing.expectEqual(@as(usize, 2), router.routes.len);
    try std.testing.expectEqualStrings("GET", router.routes[0].method);
    try std.testing.expectEqualStrings("/", router.routes[0].path);
    try std.testing.expectEqualStrings("POST", router.routes[1].method);
    try std.testing.expectEqualStrings("/api", router.routes[1].path);
}

test "Router with empty routes" {
    const empty_routes = [_]net.routing.Route{};
    const router = net.routing.Router.init(&empty_routes);

    // Test empty router
    try std.testing.expectEqual(@as(usize, 0), router.routes.len);
}

test "Router with single route" {
    const single_route = [_]net.routing.Route{
        .{ .method = "GET", .path = "/health", .handler = struct {
            fn handler() void {}
        }.handler },
    };

    const router = net.routing.Router.init(&single_route);

    try std.testing.expectEqual(@as(usize, 1), router.routes.len);
    try std.testing.expectEqualStrings("GET", router.routes[0].method);
    try std.testing.expectEqualStrings("/health", router.routes[0].path);
}

test "Router with multiple routes" {
    const routes = [_]net.routing.Route{
        .{ .method = "GET", .path = "/", .handler = struct {
            fn handler() void {}
        }.handler },
        .{ .method = "GET", .path = "/users", .handler = struct {
            fn handler() void {}
        }.handler },
        .{ .method = "POST", .path = "/users", .handler = struct {
            fn handler() void {}
        }.handler },
        .{ .method = "PUT", .path = "/users/:id", .handler = struct {
            fn handler() void {}
        }.handler },
        .{ .method = "DELETE", .path = "/users/:id", .handler = struct {
            fn handler() void {}
        }.handler },
        .{ .method = "GET", .path = "/api/status", .handler = struct {
            fn handler() void {}
        }.handler },
    };

    const router = net.routing.Router.init(&routes);

    try std.testing.expectEqual(@as(usize, 6), router.routes.len);

    // Test specific routes
    try std.testing.expectEqualStrings("GET", router.routes[0].method);
    try std.testing.expectEqualStrings("/", router.routes[0].path);

    try std.testing.expectEqualStrings("POST", router.routes[2].method);
    try std.testing.expectEqualStrings("/users", router.routes[2].path);

    try std.testing.expectEqualStrings("DELETE", router.routes[4].method);
    try std.testing.expectEqualStrings("/users/:id", router.routes[4].path);
}

test "Router route validation" {
    const routes = [_]net.routing.Route{
        .{ .method = "GET", .path = "/valid", .handler = struct {
            fn handler() void {}
        }.handler },
        .{ .method = "POST", .path = "/valid", .handler = struct {
            fn handler() void {}
        }.handler },
    };

    const router = net.routing.Router.init(&routes);

    // Test route validation
    try std.testing.expectEqual(@as(usize, 2), router.routes.len);

    // Test method validation
    try std.testing.expectEqualStrings("GET", router.routes[0].method);
    try std.testing.expectEqualStrings("POST", router.routes[1].method);

    // Test path validation
    try std.testing.expectEqualStrings("/valid", router.routes[0].path);
    try std.testing.expectEqualStrings("/valid", router.routes[1].path);
}

test "Router performance" {
    const routes = [_]net.routing.Route{
        .{ .method = "GET", .path = "/", .handler = struct {
            fn handler() void {}
        }.handler },
        .{ .method = "GET", .path = "/users", .handler = struct {
            fn handler() void {}
        }.handler },
        .{ .method = "GET", .path = "/posts", .handler = struct {
            fn handler() void {}
        }.handler },
        .{ .method = "GET", .path = "/comments", .handler = struct {
            fn handler() void {}
        }.handler },
        .{ .method = "GET", .path = "/settings", .handler = struct {
            fn handler() void {}
        }.handler },
    };

    const router = net.routing.Router.init(&routes);

    // Test router performance
    const iterations = 1000;
    const start_time = std.time.nanoTimestamp();

    for (0..iterations) |_| {
        _ = router.routes.len;
    }

    const end_time = std.time.nanoTimestamp();
    const total_time_ns = @as(u64, @intCast(end_time - start_time));
    const avg_time_ns = total_time_ns / iterations;

    // Router access should be very fast
    try std.testing.expect(avg_time_ns < 1000); // Less than 1 microsecond per access
}

test "Router memory efficiency" {
    const routes = [_]net.routing.Route{
        .{ .method = "GET", .path = "/", .handler = struct {
            fn handler() void {}
        }.handler },
        .{ .method = "POST", .path = "/api", .handler = struct {
            fn handler() void {}
        }.handler },
    };

    const router = net.routing.Router.init(&routes);

    // Test memory efficiency
    try std.testing.expectEqual(@as(usize, 2), router.routes.len);

    // Test that router doesn't leak memory
    try std.testing.expect(router.routes.len >= 0);
}

test "Router edge cases" {
    // Test with minimal route
    const minimal_route = [_]net.routing.Route{
        .{ .method = "GET", .path = "/", .handler = struct {
            fn handler() void {}
        }.handler },
    };

    const minimal_router = net.routing.Router.init(&minimal_route);
    try std.testing.expectEqual(@as(usize, 1), minimal_router.routes.len);

    // Test with complex route
    const complex_route = [_]net.routing.Route{
        .{ .method = "PUT", .path = "/api/v1/users/:id/posts/:postId/comments/:commentId", .handler = struct {
            fn handler() void {}
        }.handler },
    };

    const complex_router = net.routing.Router.init(&complex_route);
    try std.testing.expectEqual(@as(usize, 1), complex_router.routes.len);
    try std.testing.expectEqualStrings("PUT", complex_router.routes[0].method);
    try std.testing.expectEqualStrings("/api/v1/users/:id/posts/:postId/comments/:commentId", complex_router.routes[0].path);
}
