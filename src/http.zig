// Nen Net - HTTP Module
// High-performance HTTP server with static allocation

const std = @import("std");
const config = @import("config.zig");
const tcp = @import("tcp.zig");

// HTTP methods
pub const Method = enum {
    GET,
    POST,
    PUT,
    DELETE,
    HEAD,
    OPTIONS,
    PATCH,
};

// HTTP status codes
pub const StatusCode = enum(u16) {
    OK = 200,
    CREATED = 201,
    NO_CONTENT = 204,
    BAD_REQUEST = 400,
    UNAUTHORIZED = 401,
    FORBIDDEN = 403,
    NOT_FOUND = 404,
    METHOD_NOT_ALLOWED = 405,
    INTERNAL_SERVER_ERROR = 500,
    NOT_IMPLEMENTED = 501,
    SERVICE_UNAVAILABLE = 503,
};

// HTTP header
pub const Header = struct {
    name: []const u8,
    value: []const u8,
};

// HTTP request with static allocation
pub const HttpRequest = struct {
    method: Method,
    path: []const u8,
    headers: [32]Header = [_]Header{.{ .name = "", .value = "" }} ** 32,
    header_count: u8 = 0,
    body: []const u8 = "",
    version: []const u8 = "HTTP/1.1",

    pub inline fn addHeader(self: *@This(), name: []const u8, value: []const u8) !void {
        if (self.header_count >= 32) return error.TooManyHeaders;
        self.headers[self.header_count] = Header{ .name = name, .value = value };
        self.header_count += 1;
    }

    pub inline fn getHeader(self: *const @This(), name: []const u8) ?[]const u8 {
        for (0..self.header_count) |i| {
            if (std.mem.eql(u8, self.headers[i].name, name)) {
                return self.headers[i].value;
            }
        }
        return null;
    }
};

// HTTP response with static allocation
pub const HttpResponse = struct {
    status_code: StatusCode,
    headers: [32]Header = [_]Header{.{ .name = "", .value = "" }} ** 32,
    header_count: u8 = 0,
    body: []const u8 = "",
    version: []const u8 = "HTTP/1.1",

    pub inline fn addHeader(self: *@This(), name: []const u8, value: []const u8) !void {
        if (self.header_count >= 32) return error.TooManyHeaders;
        self.headers[self.header_count] = Header{ .name = name, .value = value };
        self.header_count += 1;
    }

    pub inline fn setBody(self: *@This(), body: []const u8) void {
        self.body = body;
    }
};

// Route handler function type
pub const RouteHandler = *const fn (*HttpRequest, *HttpResponse) void;

// Route definition
pub const Route = struct {
    method: Method,
    path: []const u8,
    handler: RouteHandler,
};

// HTTP server with static allocation
pub const HttpServer = struct {
    config: config.ServerConfig,
    routes: [64]Route = [_]Route{.{ .method = .GET, .path = "", .handler = undefined }} ** 64,
    route_count: u8 = 0,
    tcp_server: tcp.TcpServer,
    is_running: bool = false,

    pub inline fn init(config_options: config.ServerConfig) !@This() {
        const tcp_config = config.ServerConfig{
            .port = config_options.port,
            .max_connections = config_options.max_connections,
            .request_buffer_size = config_options.request_buffer_size,
            .response_buffer_size = config_options.response_buffer_size,
        };

        return @This(){
            .config = config_options,
            .tcp_server = tcp.TcpServer.init(tcp_config),
        };
    }

    pub inline fn addRoute(self: *@This(), method: Method, path: []const u8, handler: RouteHandler) !void {
        if (self.route_count >= 64) return error.TooManyRoutes;
        self.routes[self.route_count] = Route{ .method = method, .path = path, .handler = handler };
        self.route_count += 1;
    }

    pub inline fn findRoute(self: *const @This(), method: Method, path: []const u8) ?RouteHandler {
        for (0..self.route_count) |i| {
            if (self.routes[i].method == method and std.mem.eql(u8, self.routes[i].path, path)) {
                return self.routes[i].handler;
            }
        }
        return null;
    }

    pub inline fn start(self: *@This()) !void {
        self.is_running = true;
        try self.tcp_server.start();
    }

    pub inline fn stop(self: *@This()) void {
        self.is_running = false;
        self.tcp_server.stop();
    }

    pub inline fn isRunning(self: *const @This()) bool {
        return self.is_running;
    }
};

// HTTP parsing utilities
pub const HttpParser = struct {
    pub inline fn parseMethod(method_str: []const u8) ?Method {
        if (std.mem.eql(u8, method_str, "GET")) return .GET;
        if (std.mem.eql(u8, method_str, "POST")) return .POST;
        if (std.mem.eql(u8, method_str, "PUT")) return .PUT;
        if (std.mem.eql(u8, method_str, "DELETE")) return .DELETE;
        if (std.mem.eql(u8, method_str, "HEAD")) return .HEAD;
        if (std.mem.eql(u8, method_str, "OPTIONS")) return .OPTIONS;
        if (std.mem.eql(u8, method_str, "PATCH")) return .PATCH;
        return null;
    }

    pub inline fn parseRequestLine(request_line: []const u8) ?struct { Method, []const u8, []const u8 } {
        var parts = std.mem.splitScalar(u8, request_line, ' ');
        const method_str = parts.next() orelse return null;
        const path = parts.next() orelse return null;
        const version = parts.next() orelse return null;

        const method = parseMethod(method_str) orelse return null;
        return .{ method, path, version };
    }

    pub inline fn formatResponse(response: *const HttpResponse, buffer: []u8) ![]u8 {
        var stream = std.io.fixedBufferStream(buffer);
        var writer = stream.writer();

        // Status line
        try writer.print("{s} {d} {s}\r\n", .{ response.version, @intFromEnum(response.status_code), statusText(response.status_code) });

        // Headers
        for (0..response.header_count) |i| {
            try writer.print("{s}: {s}\r\n", .{ response.headers[i].name, response.headers[i].value });
        }

        // Content-Length if body exists
        if (response.body.len > 0) {
            try writer.print("Content-Length: {d}\r\n", .{response.body.len});
        }

        // End headers
        try writer.writeAll("\r\n");

        // Body
        if (response.body.len > 0) {
            try writer.writeAll(response.body);
        }

        return buffer[0..stream.pos];
    }

    pub inline fn statusText(status: StatusCode) []const u8 {
        return switch (status) {
            .OK => "OK",
            .CREATED => "Created",
            .NO_CONTENT => "No Content",
            .BAD_REQUEST => "Bad Request",
            .UNAUTHORIZED => "Unauthorized",
            .FORBIDDEN => "Forbidden",
            .NOT_FOUND => "Not Found",
            .METHOD_NOT_ALLOWED => "Method Not Allowed",
            .INTERNAL_SERVER_ERROR => "Internal Server Error",
            .NOT_IMPLEMENTED => "Not Implemented",
            .SERVICE_UNAVAILABLE => "Service Unavailable",
        };
    }
};
