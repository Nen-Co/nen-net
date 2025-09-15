// Nen Net Library - Main Entry Point with Data-Oriented Design
// High-performance, statically allocated HTTP and TCP framework
// Now integrated with nen-core for unified DOD patterns
//
// I/O Strategy:
// - Network I/O: Uses std.net and std.posix for platform-specific socket operations
//   (TCP sockets require low-level system calls that can't be abstracted)
// - HTTP formatting: Uses std.io.fixedBufferStream for simple buffer operations
// - File I/O: Use nen-io for file operations and validation
// - Future: Consider replacing std.io.fixedBufferStream with nen-io equivalent

const std = @import("std");
const nen_core = @import("nen-core");
const nen_io = @import("nen-io");
const nen_json = @import("nen-json");

// DOD modules
pub const dod_config = @import("dod_config.zig");
pub const dod_layout = @import("dod_layout.zig");
pub const simd_network = @import("simd_network.zig");

// Core modules
pub const config = @import("config.zig");
pub const http = @import("http.zig");
pub const tcp = @import("tcp.zig");
pub const websocket = @import("websocket.zig");
pub const connection = @import("connection.zig");
pub const routing = @import("routing.zig");
pub const performance = @import("performance.zig");
pub const tls = @import("tls.zig");

// Re-export DOD types
pub const DODNetworkLayout = dod_layout.DODNetworkLayout;
pub const SIMDNetworkProcessor = simd_network.SIMDNetworkProcessor;
pub const DODHttpParser = simd_network.DODHttpParser;

// Re-export DOD configuration
pub const ConnectionState = dod_config.ConnectionState;
pub const HttpMethod = dod_config.HttpMethod;
pub const HttpStatus = dod_config.HttpStatus;
pub const ProtocolType = dod_config.ProtocolType;
pub const DOD_CONSTANTS = dod_config.DOD_CONSTANTS;

// Re-export nen-core types for unified ecosystem
pub const NenError = nen_core.NenError;
pub const MessageType = nen_core.MessageType;
pub const BatchResult = nen_core.BatchResult;
pub const ClientBatcher = nen_core.ClientBatcher;
pub const DODConstants = nen_core.DODConstants;

// Re-export nen-io types for unified ecosystem
pub const Terminal = nen_io.Terminal;
pub const ValidationResult = nen_io.ValidationResult;
pub const ValidationError = nen_io.ValidationError;
pub const JsonValidator = nen_io.JsonValidator;
pub const FileBatch = nen_io.FileBatch;
pub const NetworkBatch = nen_io.NetworkBatch;
pub const MemoryBatch = nen_io.MemoryBatch;
pub const StreamBatch = nen_io.StreamBatch;

// Re-export nen-json types for unified ecosystem
pub const JsonValue = nen_json.JsonValue;
pub const JsonObject = nen_json.JsonObject;
pub const JsonArray = nen_json.JsonArray;
pub const JsonParser = nen_json.JsonParser;
pub const JsonSerializer = nen_json.JsonSerializer;
pub const JsonBuilder = nen_json.JsonBuilder;
pub const json = nen_json.json;

// Re-export main types for convenience
pub const HttpServer = http.HttpServer;
pub const HttpRequest = http.HttpRequest;
pub const HttpResponse = http.HttpResponse;
pub const HttpParser = http.HttpParser;
pub const Method = http.Method;
pub const StatusCode = http.StatusCode;
pub const Header = http.Header;
pub const RouteHandler = http.RouteHandler;
pub const Route = http.Route;

pub const TcpClient = tcp.TcpClient;
pub const TcpServer = tcp.TcpServer;
pub const WebSocketServer = websocket.WebSocketServer;
pub const Connection = connection.Connection;
pub const Router = routing.Router;
pub const PerformanceMonitor = performance.PerformanceMonitor;
pub const TlsConfig = tls.TlsConfig;
pub const TlsContext = tls.TlsContext;

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
    });
}

// DOD convenience functions
pub inline fn get_global_layout() *DODNetworkLayout {
    return dod_layout.get_global_layout();
}

pub inline fn get_global_processor() *SIMDNetworkProcessor {
    return simd_network.get_global_processor();
}

pub inline fn process_mixed_batches(connection_count: u32, request_count: u32, response_count: u32) void {
    const layout = get_global_layout();
    simd_network.process_mixed_network_batches(layout, connection_count, request_count, response_count);
}

pub inline fn createTcpClient(host: []const u8, port: u16) !TcpClient {
    return TcpClient.init(.{
        .host = host,
        .port = port,
        .buffer_size = config.client_buffer_size,
    });
}

pub inline fn createTcpServer(port: u16) !TcpServer {
    const server_config = config.ServerConfig{
        .port = port,
        .max_connections = 4096,
        .request_buffer_size = 8192,
        .response_buffer_size = 8192,
    };
    return try TcpServer.init(server_config);
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
