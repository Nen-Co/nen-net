// Nen Net - HTTP Module
// High-performance HTTP server with static allocation

const std = @import("std");
const config = @import("config.zig");
const tcp = @import("tcp.zig");
const nen_json = @import("nen-json");
const routing = @import("routing.zig");

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

// Path parameter for route matching
pub const PathParam = struct {
    name: []const u8,
    value: []const u8,
};

// Query parameter
pub const QueryParam = struct {
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

    // Path parameters from route matching
    path_params: [8]PathParam = [_]PathParam{.{ .name = "", .value = "" }} ** 8,
    path_param_count: u8 = 0,

    // Query parameters
    query_params: [32]QueryParam = [_]QueryParam{.{ .name = "", .value = "" }} ** 32,
    query_param_count: u8 = 0,
    query_parsed: bool = false,

    // Raw query string
    query_string: []const u8 = "",

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

    pub inline fn setPathParams(self: *@This(), params: []const []const u8) void {
        self.path_param_count = @intCast(@min(params.len, 8));
        for (0..self.path_param_count) |i| {
            self.path_params[i].name = params[i];
        }
    }

    pub inline fn param(self: *const @This(), name: []const u8) ?[]const u8 {
        for (0..self.path_param_count) |i| {
            if (std.mem.eql(u8, self.path_params[i].name, name)) {
                return self.path_params[i].value;
            }
        }
        return null;
    }

    pub inline fn parseQuery(self: *@This()) !void {
        if (self.query_parsed) return;

        var query_str = self.query_string;
        var param_count: u8 = 0;

        while (query_str.len > 0 and param_count < 32) {
            const eq_pos = std.mem.indexOfScalar(u8, query_str, '=');
            if (eq_pos == null) break;

            const name = query_str[0..eq_pos.?];
            query_str = query_str[eq_pos.? + 1 ..];

            const amp_pos = std.mem.indexOfScalar(u8, query_str, '&');
            const value = if (amp_pos) |pos| query_str[0..pos] else query_str;

            self.query_params[param_count] = QueryParam{
                .name = name,
                .value = value,
            };
            param_count += 1;

            if (amp_pos) |pos| {
                query_str = query_str[pos + 1 ..];
            } else {
                break;
            }
        }

        self.query_param_count = param_count;
        self.query_parsed = true;
    }

    pub inline fn query(self: *@This()) ![]const QueryParam {
        try self.parseQuery();
        return self.query_params[0..self.query_param_count];
    }

    pub inline fn getQueryParam(self: *@This(), name: []const u8) !?[]const u8 {
        try self.parseQuery();
        for (0..self.query_param_count) |i| {
            if (std.mem.eql(u8, self.query_params[i].name, name)) {
                return self.query_params[i].value;
            }
        }
        return null;
    }
};

// Content type enum
pub const ContentType = enum {
    TEXT,
    HTML,
    JSON,
    XML,
    CSS,
    JS,
    PNG,
    JPG,
    GIF,
    SVG,
    PDF,
    BINARY,
    UNKNOWN,

    pub inline fn toString(self: @This()) []const u8 {
        return switch (self) {
            .TEXT => "text/plain",
            .HTML => "text/html",
            .JSON => "application/json",
            .XML => "application/xml",
            .CSS => "text/css",
            .JS => "application/javascript",
            .PNG => "image/png",
            .JPG => "image/jpeg",
            .GIF => "image/gif",
            .SVG => "image/svg+xml",
            .PDF => "application/pdf",
            .BINARY => "application/octet-stream",
            .UNKNOWN => "application/octet-stream",
        };
    }
};

// HTTP response with static allocation
pub const HttpResponse = struct {
    status_code: StatusCode,
    headers: [32]Header = [_]Header{.{ .name = "", .value = "" }} ** 32,
    header_count: u8 = 0,
    body: []const u8 = "",
    version: []const u8 = "HTTP/1.1",
    content_type: ContentType = .TEXT,
    written: bool = false,

    pub inline fn addHeader(self: *@This(), name: []const u8, value: []const u8) !void {
        if (self.header_count >= 32) return error.TooManyHeaders;
        self.headers[self.header_count] = Header{ .name = name, .value = value };
        self.header_count += 1;
    }

    pub inline fn setBody(self: *@This(), body: []const u8) void {
        self.body = body;
    }

    pub inline fn setStatus(self: *@This(), status: StatusCode) void {
        self.status_code = status;
    }

    pub inline fn setContentType(self: *@This(), content_type: ContentType) void {
        self.content_type = content_type;
        self.addHeader("Content-Type", content_type.toString()) catch {};
    }

    // JSON response helpers
    pub inline fn json(self: *@This(), value: anytype) !void {
        self.setContentType(.JSON);
        const json_string = try nen_json.json.stringify(value);
        self.body = json_string;
        try self.addHeader("Content-Length", try std.fmt.allocPrint(std.heap.page_allocator, "{d}", .{json_string.len}));
    }

    pub inline fn setJsonBody(self: *@This(), json_value: nen_json.JsonValue) !void {
        try self.json(json_value);
    }

    pub inline fn setJsonObject(self: *@This(), obj: nen_json.JsonObject) !void {
        const json_value = nen_json.JsonValue{ .object = obj };
        try self.setJsonBody(json_value);
    }

    pub inline fn setJsonArray(self: *@This(), arr: nen_json.JsonArray) !void {
        const json_value = nen_json.JsonValue{ .array = arr };
        try self.setJsonBody(json_value);
    }

    pub inline fn setJsonString(self: *@This(), str: []const u8) !void {
        const json_value = nen_json.json.string(str);
        try self.setJsonBody(json_value);
    }

    pub inline fn setJsonNumber(self: *@This(), num: f64) !void {
        const json_value = nen_json.json.number(num);
        try self.setJsonBody(json_value);
    }

    pub inline fn setJsonBoolean(self: *@This(), bool_val: bool) !void {
        const json_value = nen_json.json.boolean(bool_val);
        try self.setJsonBody(json_value);
    }

    // Text response helpers
    pub inline fn text(self: *@This(), text_content: []const u8) void {
        self.setContentType(.TEXT);
        self.body = text_content;
        self.addHeader("Content-Length", std.fmt.allocPrint(std.heap.page_allocator, "{d}", .{text_content.len}) catch "0") catch {};
    }

    pub inline fn html(self: *@This(), html_content: []const u8) void {
        self.setContentType(.HTML);
        self.body = html_content;
        self.addHeader("Content-Length", std.fmt.allocPrint(std.heap.page_allocator, "{d}", .{html_content.len}) catch "0") catch {};
    }

    // Writer for streaming responses
    pub inline fn writer(self: *@This()) ResponseWriter {
        return ResponseWriter{ .response = self };
    }

    // Write response (mark as written)
    pub inline fn write(self: *@This()) void {
        self.written = true;
    }
};

// Response writer for streaming
pub const ResponseWriter = struct {
    response: *HttpResponse,
    buffer: [4096]u8 = undefined,
    pos: usize = 0,

    pub inline fn print(self: *@This(), comptime fmt: []const u8, args: anytype) !void {
        const result = try std.fmt.bufPrint(self.buffer[self.pos..], fmt, args);
        self.pos += result.len;
        if (self.pos >= self.buffer.len) {
            self.pos = self.buffer.len - 1;
        }
    }

    pub inline fn writeAll(self: *@This(), data: []const u8) !void {
        const remaining = self.buffer.len - self.pos;
        const to_write = @min(data.len, remaining);
        @memcpy(self.buffer[self.pos .. self.pos + to_write], data[0..to_write]);
        self.pos += to_write;
    }

    pub inline fn flush(self: *@This()) void {
        self.response.body = self.buffer[0..self.pos];
        self.response.written = true;
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

// HTTP server with static allocation and advanced routing
pub const HttpServer = struct {
    config: config.ServerConfig,
    tcp_server: tcp.TcpServer,
    is_running: bool = false,
    router: ?*routing.Router = null,

    pub inline fn init(config_options: config.ServerConfig) !@This() {
        const tcp_config = config.ServerConfig{
            .port = config_options.port,
            .max_connections = config_options.max_connections,
            .request_buffer_size = config_options.request_buffer_size,
            .response_buffer_size = config_options.response_buffer_size,
        };

        return @This(){
            .config = config_options,
            .tcp_server = try tcp.TcpServer.init(tcp_config),
        };
    }

    pub inline fn setRouter(self: *@This(), router: *routing.Router) void {
        self.router = router;
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

    // Process HTTP request with routing
    pub inline fn handleRequest(self: *@This(), req: *HttpRequest, res: *HttpResponse) void {
        if (self.router) |router| {
            const http_method = routing.HttpMethod.fromString(@tagName(req.method)) orelse .OTHER;
            var params: [8]routing.PathParam = undefined;

            if (router.findRoute(http_method, req.path, &params)) |route_match| {
                // Set path parameters in request
                for (0..route_match[1]) |i| {
                    req.path_params[i] = PathParam{
                        .name = params[i].name,
                        .value = params[i].value,
                    };
                }
                req.path_param_count = @intCast(route_match[1]);

                // Execute the route
                router.executeRoute(route_match[0], req, res, route_match[1]);
            } else {
                // No route found - 404
                res.setStatus(.NOT_FOUND);
                res.text("Not Found");
            }
        } else {
            // No router - 500
            res.setStatus(.INTERNAL_SERVER_ERROR);
            res.text("No router configured");
        }
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
