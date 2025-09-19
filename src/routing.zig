// Nen Net - Advanced Routing Module
// Comprehensive router with path parameters, middleware, and groups
// Follows DOD principles with static allocation

const std = @import("std");
const http = @import("http.zig");

// HTTP Method enum for type safety
pub const HttpMethod = enum {
    GET,
    POST,
    PUT,
    DELETE,
    HEAD,
    OPTIONS,
    PATCH,
    CONNECT,
    TRACE,
    OTHER, // For custom methods

    pub inline fn fromString(method_str: []const u8) ?@This() {
        if (std.mem.eql(u8, method_str, "GET")) return .GET;
        if (std.mem.eql(u8, method_str, "POST")) return .POST;
        if (std.mem.eql(u8, method_str, "PUT")) return .PUT;
        if (std.mem.eql(u8, method_str, "DELETE")) return .DELETE;
        if (std.mem.eql(u8, method_str, "HEAD")) return .HEAD;
        if (std.mem.eql(u8, method_str, "OPTIONS")) return .OPTIONS;
        if (std.mem.eql(u8, method_str, "PATCH")) return .PATCH;
        if (std.mem.eql(u8, method_str, "CONNECT")) return .CONNECT;
        if (std.mem.eql(u8, method_str, "TRACE")) return .TRACE;
        return .OTHER;
    }

    pub inline fn toString(self: @This()) []const u8 {
        return switch (self) {
            .GET => "GET",
            .POST => "POST",
            .PUT => "PUT",
            .DELETE => "DELETE",
            .HEAD => "HEAD",
            .OPTIONS => "OPTIONS",
            .PATCH => "PATCH",
            .CONNECT => "CONNECT",
            .TRACE => "TRACE",
            .OTHER => "OTHER",
        };
    }
};

// Path parameter extraction
pub const PathParam = struct {
    name: []const u8,
    value: []const u8,
};

// Route handler function type
pub const RouteHandler = *const fn (*http.HttpRequest, *http.HttpResponse) void;

// Middleware function type - using opaque pointer to avoid circular dependency
pub const Middleware = *const fn (*http.HttpRequest, *http.HttpResponse, *anyopaque) void;

// Middleware executor for chaining
pub const MiddlewareExecutor = struct {
    index: usize,
    middlewares: []const Middleware,
    handler: RouteHandler,
    req: *http.HttpRequest,
    res: *http.HttpResponse,

    pub inline fn next(self: *@This()) void {
        if (self.index < self.middlewares.len) {
            const middleware = self.middlewares[self.index];
            self.index += 1;
            middleware(self.req, self.res, self);
        } else {
            // Execute the final handler
            self.handler(self.req, self.res);
        }
    }
};

// Route configuration
pub const RouteConfig = struct {
    middlewares: []const Middleware = &.{},
    data: ?*const anyopaque = null,
    dispatcher: ?*const fn (*http.HttpRequest, *http.HttpResponse) void = null,
};

// Route definition with enhanced features
pub const Route = struct {
    method: HttpMethod,
    path: []const u8,
    handler: RouteHandler,
    config: RouteConfig = .{},
    param_names: [8][]const u8 = [_][]const u8{""} ** 8,
    param_count: u8 = 0,
    is_glob: bool = false,
    glob_pattern: []const u8 = "",

    pub inline fn init(method: HttpMethod, path: []const u8, handler: RouteHandler) @This() {
        var route = @This(){
            .method = method,
            .path = path,
            .handler = handler,
        };
        route.parsePath();
        return route;
    }

    pub inline fn withConfig(method: HttpMethod, path: []const u8, handler: RouteHandler, config: RouteConfig) @This() {
        var route = @This(){
            .method = method,
            .path = path,
            .handler = handler,
            .config = config,
        };
        route.parsePath();
        return route;
    }

    // Parse path to extract parameter names
    fn parsePath(self: *@This()) void {
        var path = self.path;
        var param_index: u8 = 0;
        var i: usize = 0;

        while (i < path.len and param_index < 8) {
            if (path[i] == ':') {
                // Found parameter start
                i += 1;
                const start = i;
                while (i < path.len and path[i] != '/' and path[i] != '*') {
                    i += 1;
                }
                if (i > start) {
                    self.param_names[param_index] = path[start..i];
                    param_index += 1;
                }
            } else if (path[i] == '*') {
                // Found glob pattern
                self.is_glob = true;
                self.glob_pattern = path[i..];
                break;
            } else {
                i += 1;
            }
        }
        self.param_count = param_index;
    }

    // Match route and extract parameters
    pub inline fn matches(self: *const @This(), method: HttpMethod, path: []const u8, params: *[8]PathParam) ?u8 {
        if (self.method != method and self.method != .OTHER) return null;

        if (self.is_glob) {
            return self.matchGlob(path, params);
        } else {
            return self.matchExact(path, params);
        }
    }

    fn matchExact(self: *const @This(), path: []const u8, params: *[8]PathParam) ?u8 {
        var route_parts = std.mem.splitScalar(u8, self.path, '/');
        var path_parts = std.mem.splitScalar(u8, path, '/');
        var param_count: u8 = 0;

        while (route_parts.next()) |route_part| {
            const path_part = path_parts.next() orelse return null;

            if (route_part.len > 0 and route_part[0] == ':') {
                // This is a parameter
                if (param_count < 8) {
                    params[param_count] = PathParam{
                        .name = self.param_names[param_count],
                        .value = path_part,
                    };
                    param_count += 1;
                }
            } else if (!std.mem.eql(u8, route_part, path_part)) {
                return null;
            }
        }

        // Check if path has more parts
        if (path_parts.next() != null) return null;

        return param_count;
    }

    fn matchGlob(self: *const @This(), path: []const u8, params: *[8]PathParam) ?u8 {
        _ = path;
        _ = params;
        // Simple glob matching - can be enhanced
        if (self.glob_pattern.len == 1 and self.glob_pattern[0] == '*') {
            // Match everything
            return 0;
        }
        // More complex glob patterns can be implemented here
        return null;
    }
};

// Route group for organizing routes
pub const RouteGroup = struct {
    prefix: []const u8,
    config: RouteConfig,
    routes: []Route,
    route_count: u8 = 0,

    pub inline fn init(prefix: []const u8, config: RouteConfig, routes: []Route) @This() {
        return @This(){
            .prefix = prefix,
            .config = config,
            .routes = routes,
        };
    }

    pub inline fn addRoute(self: *@This(), method: HttpMethod, path: []const u8, handler: RouteHandler) !void {
        if (self.route_count >= self.routes.len) return error.TooManyRoutes;

        const full_path = try std.fmt.allocPrint(std.heap.page_allocator, "{s}{s}", .{ self.prefix, path });
        defer std.heap.page_allocator.free(full_path);

        self.routes[self.route_count] = Route.withConfig(method, full_path, handler, self.config);
        self.route_count += 1;
    }
};

// Advanced router with static allocation
pub const Router = struct {
    routes: [128]Route = [_]Route{undefined} ** 128,
    route_count: u8 = 0,
    middlewares: [16]Middleware = [_]Middleware{undefined} ** 16,
    middleware_count: u8 = 0,

    pub inline fn init() @This() {
        return @This(){};
    }

    pub inline fn addRoute(self: *@This(), http_method: HttpMethod, path: []const u8, handler: RouteHandler) !void {
        if (self.route_count >= 128) return error.TooManyRoutes;
        self.routes[self.route_count] = Route.init(http_method, path, handler);
        self.route_count += 1;
    }

    pub inline fn addRouteWithConfig(self: *@This(), http_method: HttpMethod, path: []const u8, handler: RouteHandler, config: RouteConfig) !void {
        if (self.route_count >= 128) return error.TooManyRoutes;
        self.routes[self.route_count] = Route.withConfig(http_method, path, handler, config);
        self.route_count += 1;
    }

    pub inline fn addMiddleware(self: *@This(), middleware: Middleware) !void {
        if (self.middleware_count >= 16) return error.TooManyMiddlewares;
        self.middlewares[self.middleware_count] = middleware;
        self.middleware_count += 1;
    }

    pub inline fn findRoute(self: *const @This(), http_method: HttpMethod, path: []const u8, params: *[8]PathParam) ?struct { *const Route, u8 } {
        var best_match: ?struct { *const Route, u8 } = null;
        var best_score: u8 = 0;

        for (0..self.route_count) |i| {
            const route = &self.routes[i];
            if (route.matches(http_method, path, params)) |param_count| {
                // Score based on specificity (more specific routes win)
                const score = if (route.is_glob) 0 else @as(u8, @intCast(route.param_count));
                if (score > best_score) {
                    best_match = .{ route, param_count };
                    best_score = score;
                }
            }
        }

        return best_match;
    }

    pub inline fn executeRoute(self: *const @This(), route: *const Route, req: *http.HttpRequest, res: *http.HttpResponse, param_count: u8) void {
        _ = self;
        // Set path parameters in request
        req.setPathParams(route.param_names[0..param_count]);

        // Execute middlewares and handler
        var executor = MiddlewareExecutor{
            .index = 0,
            .middlewares = route.config.middlewares,
            .handler = route.handler,
            .req = req,
            .res = res,
        };

        if (route.config.dispatcher) |dispatcher| {
            dispatcher(req, res);
        } else {
            executor.next();
        }
    }

    // Convenience methods for different HTTP methods
    pub inline fn get(self: *@This(), path: []const u8, handler: RouteHandler) !void {
        try self.addRoute(.GET, path, handler);
    }

    pub inline fn post(self: *@This(), path: []const u8, handler: RouteHandler) !void {
        try self.addRoute(.POST, path, handler);
    }

    pub inline fn put(self: *@This(), path: []const u8, handler: RouteHandler) !void {
        try self.addRoute(.PUT, path, handler);
    }

    pub inline fn delete(self: *@This(), path: []const u8, handler: RouteHandler) !void {
        try self.addRoute(.DELETE, path, handler);
    }

    pub inline fn head(self: *@This(), path: []const u8, handler: RouteHandler) !void {
        try self.addRoute(.HEAD, path, handler);
    }

    pub inline fn options(self: *@This(), path: []const u8, handler: RouteHandler) !void {
        try self.addRoute(.OPTIONS, path, handler);
    }

    pub inline fn patch(self: *@This(), path: []const u8, handler: RouteHandler) !void {
        try self.addRoute(.PATCH, path, handler);
    }

    pub inline fn all(self: *@This(), path: []const u8, handler: RouteHandler) !void {
        // Add for all common methods
        try self.addRoute(.GET, path, handler);
        try self.addRoute(.POST, path, handler);
        try self.addRoute(.PUT, path, handler);
        try self.addRoute(.DELETE, path, handler);
        try self.addRoute(.HEAD, path, handler);
        try self.addRoute(.OPTIONS, path, handler);
        try self.addRoute(.PATCH, path, handler);
    }

    pub inline fn method(self: *@This(), method_str: []const u8, path: []const u8, handler: RouteHandler) !void {
        const http_method = HttpMethod.fromString(method_str) orelse .OTHER;
        try self.addRoute(http_method, path, handler);
    }
};

// Error types
pub const RouterError = error{
    TooManyRoutes,
    TooManyMiddlewares,
    InvalidPath,
    InvalidMethod,
};
