// Nen Net Library - Main Entry Point
// High-performance, statically allocated HTTP and TCP framework

const std = @import("std");

// Core modules
pub const config = @import("config.zig");
pub const http = @import("http.zig");
pub const tcp = @import("tcp.zig");
pub const websocket = @import("websocket.zig");
pub const connection = @import("connection.zig");
pub const routing = @import("routing.zig");
pub const performance = @import("performance.zig");

// Re-export main types for convenience
pub const HttpServer = http.HttpServer;
pub const TcpClient = tcp.TcpClient;
pub const TcpServer = tcp.TcpServer;
pub const WebSocketServer = websocket.WebSocketServer;
pub const Connection = connection.Connection;
pub const Route = routing.Route;
pub const Router = routing.Router;
pub const PerformanceMonitor = performance.PerformanceMonitor;

// Configuration constants
pub const default_port = config.default_port;
pub const max_connections = config.max_connections;
pub const request_buffer_size = config.request_buffer_size;
pub const response_buffer_size = config.response_buffer_size;
pub const client_buffer_size = config.client_buffer_size;

// Server configuration
pub const ServerConfig = config.ServerConfig;
pub const ClientConfig = config.ClientConfig;
pub const WebSocketConfig = config.WebSocketConfig;

// Convenience functions for common operations
pub inline fn createHttpServer(port: u16) !HttpServer {
    return HttpServer.init(.{
        .port = port,
        .max_connections = config.max_connections,
        .request_buffer_size = config.request_buffer_size,
        .response_buffer_size = config.response_buffer_size,
    });
}

pub inline fn createTcpClient(host: []const u8, port: u16) !TcpClient {
    return TcpClient.init(.{
        .host = host,
        .port = port,
        .buffer_size = config.client_buffer_size,
    });
}

pub inline fn createWebSocketServer(port: u16) !WebSocketServer {
    return WebSocketServer.init(.{
        .port = port,
        .max_connections = config.max_connections,
    });
}

// Quick server setup
pub inline fn quickServer(port: u16, routes: []const Route) !HttpServer {
    var server = try createHttpServer(port);

    for (routes) |route| {
        try server.addRoute(route.method, route.path, route.handler);
    }

    return server;
}

// Performance monitoring
pub inline fn startPerformanceMonitoring() !PerformanceMonitor {
    return PerformanceMonitor.init();
}

// Inline utility functions for common operations
pub inline fn isValidServerConfig(config_options: ServerConfig) bool {
    return config.isValidPort(config_options.port) and
        config.isValidBufferSize(config_options.request_buffer_size) and
        config.isValidBufferSize(config_options.response_buffer_size) and
        config.isValidConnectionCount(config_options.max_connections);
}

pub inline fn isValidClientConfig(config_options: ClientConfig) bool {
    return config_options.host.len > 0 and
        config.isValidPort(config_options.port) and
        config.isValidBufferSize(config_options.buffer_size);
}

pub inline fn getOptimalServerConfig(port: u16, expected_connections: u32) ServerConfig {
    return ServerConfig{
        .port = port,
        .max_connections = config.getOptimalPoolSize(expected_connections),
        .request_buffer_size = config.getOptimalBufferSize(8192),
        .response_buffer_size = config.getOptimalBufferSize(16384),
    };
}

pub inline fn getOptimalClientConfig(host: []const u8, port: u16) ClientConfig {
    return ClientConfig{
        .host = host,
        .port = port,
        .buffer_size = config.getOptimalBufferSize(4096),
    };
}

// Version information
pub const VERSION = "0.1.0";
pub const VERSION_STRING = "Nen Net v" ++ VERSION;

// Feature flags
pub const FEATURES = struct {
    pub const static_memory = true; // Zero dynamic allocation
    pub const inline_functions = true; // Critical operations are inline
    pub const connection_pooling = true; // Pre-allocated connection pools
    pub const http_server = true; // HTTP/1.1 server
    pub const tcp_framework = true; // TCP client/server
    pub const websocket_support = true; // WebSocket handling
    pub const performance_monitoring = true; // Built-in performance tracking
    pub const connection_batching = true; // Connection operation batching
};

// Performance targets
pub const PERFORMANCE_TARGETS = struct {
    pub const max_concurrent_connections: u32 = 100000; // 100K concurrent connections
    pub const requests_per_second: u32 = 1000000; // 1M requests/second
    pub const max_latency_ms: u64 = 1; // <1ms latency
    pub const memory_overhead_percent: f64 = 5.0; // <5% memory overhead
    pub const startup_time_ms: u64 = 10; // <10ms startup
};

// Error types
pub const NetworkError = error{
    ConnectionFailed,
    BindFailed,
    AcceptFailed,
    SendFailed,
    ReceiveFailed,
    InvalidRequest,
    InvalidResponse,
    Timeout,
    BufferFull,
    ConnectionClosed,
    InvalidWebSocketFrame,
    UnsupportedProtocol,
    TLSNotSupported,
    CompressionFailed,
    RoutingError,
    HandlerError,
};
