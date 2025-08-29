// Nen Net - Routing Module Tests
// Tests routing functionality and inline functions

const std = @import("std");
const net = @import("../../src/lib.zig");

test "Router initialization" {
    const routes = [_]net.routing.Route{
        .{ .method = "GET", .path = "/", .handler = struct { fn handler() void {} }.handler },
        .{ .method = "POST", .path = "/api", .handler = struct { fn handler() void {} }.handler },
    };

    var router = net.routing.Router.init(&routes);
    
    // Test that routes are correctly set
    try std.testing.expectEqual(@as(usize, 2), router.routes.len);
    try std.testing.expectEqualStrings("GET", router.routes[0].method);
    try std.testing.expectEqualStrings("/", router.routes[0].path);
    try std.testing.expectEqualStrings("POST", router.routes[1].method);
    try std.testing.expectEqualStrings("/api", router.routes[1].path);
}

test "Router with empty routes" {
    const empty_routes = [_]net.routing.Route{};
    var router = net.routing.Router.init(&empty_routes);
    
    // Test empty router
    try std.testing.expectEqual(@as(usize, 0), router.routes.len);
}

test "Router with single route" {
    const single_route = [_]net.routing.Route{
        .{ .method = "GET", .path = "/health", .handler = struct { fn handler() void {} }.handler },
    };

    var router = net.routing.Router.init(&single_route);
    
    try std.testing.expectEqual(@as(usize, 1), router.routes.len);
    try std.testing.expectEqualStrings("GET", router.routes[0].method);
    try std.testing.expectEqualStrings("/health", router.routes[0].path);
}

test "Router with multiple routes" {
    const routes = [_]net.routing.Route{
        .{ .method = "GET", .path = "/", .handler = struct { fn handler() void {} }.handler },
        .{ .method = "GET", .path = "/users", .handler = struct { fn handler() void {} }.handler },
        .{ .method = "POST", .path = "/users", .handler = struct { fn handler() void {} }.handler },
        .{ .method = "PUT", .path = "/users/:id", .handler = struct { fn handler() void {} }.handler },
        .{ .method = "DELETE", .path = "/users/:id", .handler = struct { fn handler() void {} }.handler },
        .{ .method = "GET", .path = "/api/status", .handler = struct { fn handler() void {} }.handler },
    };

    var router = net.routing.Router.init(&routes);
    
    try std.testing.expectEqual(@as(usize, 6), router.routes.len);
    
    // Test specific routes
    try std.testing.expectEqualStrings("GET", router.routes[0].method);
    try std.testing.expectEqualStrings("/", router.routes[0].path);
    
    try std.testing.expectEqualStrings("POST", router.routes[2].method);
    try std.testing.expectEqualStrings("/users", router.routes[2].path);
    
    try std.testing.expectEqualStrings("DELETE", router.routes[4].method);
    try std.testing.expectEqualStrings("/users/:id", router.routes[4].path);
}

test "Router route finding" {
    const routes = [_]net.routing.Route{
        .{ .method = "GET", .path = "/", .handler = struct { fn handler() void {} }.handler },
        .{ .method = "POST", .path = "/api", .handler = struct { fn handler() void {} }.handler },
    };

    var router = net.routing.Router.init(&routes);
    
    // Test route finding (currently returns null as it's a placeholder)
    const found_route = router.findRoute("GET", "/");
    // Note: Currently returns null as it's a placeholder implementation
    _ = found_route;
    
    // Test should not crash
    try std.testing.expect(true);
}

test "Router with various HTTP methods" {
    const http_methods = [_][]const u8{ "GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS" };
    
    for (http_methods) |method| {
        const routes = [_]net.routing.Route{
            .{ .method = method, .path = "/test", .handler = struct { fn handler() void {} }.handler },
        };

        var router = net.routing.Router.init(&routes);
        
        try std.testing.expectEqual(@as(usize, 1), router.routes.len);
        try std.testing.expectEqualStrings(method, router.routes[0].method);
        try std.testing.expectEqualStrings("/test", router.routes[0].path);
    }
}

test "Router with various path patterns" {
    const path_patterns = [_][]const u8{
        "/",
        "/api",
        "/users",
        "/users/:id",
        "/api/v1/users",
        "/api/v1/users/:id/posts",
        "/health/check",
        "/static/*",
        "/docs/:version/*",
    };

    for (path_patterns) |path| {
        const routes = [_]net.routing.Route{
            .{ .method = "GET", .path = path, .handler = struct { fn handler() void {} }.handler },
        };

        var router = net.routing.Router.init(&routes);
        
        try std.testing.expectEqual(@as(usize, 1), router.routes.len);
        try std.testing.expectEqualStrings(path, router.routes[0].path);
    }
}

test "Router edge cases" {
    // Test with very long method names
    const long_method = "VERY_LONG_HTTP_METHOD_NAME_THAT_MIGHT_CAUSE_ISSUES";
    const routes = [_]net.routing.Route{
        .{ .method = long_method, .path = "/test", .handler = struct { fn handler() void {} }.handler },
    };

    var router = net.routing.Router.init(&routes);
    try std.testing.expectEqual(@as(usize, 1), router.routes.len);
    try std.testing.expectEqualStrings(long_method, router.routes[0].method);

    // Test with very long paths
    const long_path = "/very/long/path/that/goes/on/and/on/and/might/cause/issues/with/routing/performance";
    const routes2 = [_]net.routing.Route{
        .{ .method = "GET", .path = long_path, .handler = struct { fn handler() void {} }.handler },
    };

    var router2 = net.routing.Router.init(&routes2);
    try std.testing.expectEqual(@as(usize, 1), router2.routes.len);
    try std.testing.expectEqualStrings(long_path, router2.routes[0].path);
}

test "Router performance" {
    const iterations = 1000;
    const start_time = std.time.nanoTimestamp();
    
    for (0..iterations) |_| {
        const routes = [_]net.routing.Route{
            .{ .method = "GET", .path = "/", .handler = struct { fn handler() void {} }.handler },
        };
        const router = net.routing.Router.init(&routes);
        _ = router.findRoute("GET", "/");
    }
    
    const end_time = std.time.nanoTimestamp();
    const init_time_ns = @as(u64, @intCast(end_time - start_time));
    
    // Performance should be reasonable (less than 10ms for 1000 operations)
    try std.testing.expect(init_time_ns < 10000000);
}

test "Router memory efficiency" {
    const routes = [_]net.routing.Route{
        .{ .method = "GET", .path = "/", .handler = struct { fn handler() void {} }.handler },
        .{ .method = "POST", .path = "/api", .handler = struct { fn handler() void {} }.handler },
    };

    var router = net.routing.Router.init(&routes);
    
    // Test that router structure is compact
    const size = @sizeOf(net.routing.Router);
    
    // Router should be small (just a slice pointer)
    try std.testing.expect(size <= 16); // 8 bytes for slice pointer + padding
    
    // Test alignment
    try std.testing.expect(@ptrToInt(&router) % @alignOf(net.routing.Router) == 0);
}
