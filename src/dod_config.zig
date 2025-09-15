// Nen Net Library - Data-Oriented Design Configuration
// Network-specific DOD constants and structures for high-performance networking

const std = @import("std");

/// DOD constants for network operations
pub const DOD_CONSTANTS = struct {
    // Connection management
    pub const MAX_CONNECTIONS: u32 = 8192; // Max concurrent connections
    pub const MAX_HTTP_REQUESTS: u32 = 16384; // Max concurrent HTTP requests
    pub const MAX_TCP_SOCKETS: u32 = 4096; // Max TCP sockets
    pub const MAX_WEBSOCKET_CONNECTIONS: u32 = 2048; // Max WebSocket connections

    // Buffer sizes and management
    pub const REQUEST_BUFFER_SIZE: usize = 64 * 1024; // 64KB per request
    pub const RESPONSE_BUFFER_SIZE: usize = 128 * 1024; // 128KB per response
    pub const HEADER_BUFFER_SIZE: usize = 8 * 1024; // 8KB for headers
    pub const BODY_BUFFER_SIZE: usize = 1024 * 1024; // 1MB for body data

    // Network buffer pools
    pub const NETWORK_BUFFER_POOL_SIZE: usize = 64 * 1024 * 1024; // 64MB total
    pub const SOCKET_BUFFER_SIZE: usize = 32 * 1024; // 32KB per socket
    pub const PACKET_BUFFER_SIZE: usize = 16 * 1024; // 16KB per packet

    // Memory alignment
    pub const CACHE_LINE_SIZE: u32 = 64; // CPU cache line size
    pub const SIMD_ALIGNMENT: u32 = 32; // SIMD vector alignment
    pub const PAGE_SIZE: u32 = 4096; // Memory page size

    // Processing batches
    pub const CONNECTION_BATCH_SIZE: u32 = 64; // Connections per SIMD batch
    pub const REQUEST_BATCH_SIZE: u32 = 32; // Requests per SIMD batch
    pub const HEADER_BATCH_SIZE: u32 = 16; // Headers per SIMD batch
    pub const PACKET_BATCH_SIZE: u32 = 128; // Packets per SIMD batch

    // HTTP specific
    pub const MAX_HEADERS_PER_REQUEST: u32 = 64; // Max headers per HTTP request
    pub const MAX_URL_LENGTH: u32 = 2048; // Max URL length
    pub const MAX_HEADER_NAME_LENGTH: u32 = 128; // Max header name length
    pub const MAX_HEADER_VALUE_LENGTH: u32 = 4096; // Max header value length

    // Protocol limits
    pub const MAX_HTTP_VERSION_LENGTH: u32 = 16; // "HTTP/1.1" etc.
    pub const MAX_METHOD_LENGTH: u32 = 16; // "GET", "POST", etc.
    pub const MAX_STATUS_MESSAGE_LENGTH: u32 = 128; // Status message

    // Connection state
    pub const CONNECTION_TIMEOUT_MS: u32 = 30000; // 30 second timeout
    pub const KEEP_ALIVE_TIMEOUT_MS: u32 = 5000; // 5 second keep-alive
    pub const MAX_PIPELINE_DEPTH: u32 = 8; // HTTP pipelining depth
};

/// Network connection states for DOD organization
pub const ConnectionState = enum(u8) {
    inactive = 0,
    connecting = 1,
    connected = 2,
    reading = 3,
    writing = 4,
    closing = 5,
    connection_error = 6,
};

/// HTTP method types for SoA storage
pub const HttpMethod = enum(u8) {
    unknown = 0,
    get = 1,
    post = 2,
    put = 3,
    delete = 4,
    head = 5,
    options = 6,
    patch = 7,
    trace = 8,
    connect = 9,
};

/// HTTP status codes for efficient storage
pub const HttpStatus = enum(u16) {
    unknown = 0,
    ok = 200,
    created = 201,
    accepted = 202,
    no_content = 204,
    moved_permanently = 301,
    found = 302,
    not_modified = 304,
    bad_request = 400,
    unauthorized = 401,
    forbidden = 403,
    not_found = 404,
    method_not_allowed = 405,
    conflict = 409,
    internal_server_error = 500,
    not_implemented = 501,
    bad_gateway = 502,
    service_unavailable = 503,
};

/// Network protocol types
pub const ProtocolType = enum(u8) {
    unknown = 0,
    http_1_0 = 1,
    http_1_1 = 2,
    http_2_0 = 3,
    websocket = 4,
    tcp = 5,
    udp = 6,
};

/// Connection data structure for SoA layout
pub const ConnectionData = struct {
    socket_fd: i32,
    state: ConnectionState,
    protocol: ProtocolType,
    local_port: u16,
    remote_port: u16,
    bytes_read: u64,
    bytes_written: u64,
    last_activity_ms: u64,
    timeout_ms: u32,
    pipeline_depth: u8,
};

/// HTTP request data structure for SoA layout
pub const HttpRequestData = struct {
    connection_id: u32,
    method: HttpMethod,
    url_offset: u32,
    url_length: u32,
    version_offset: u32,
    version_length: u32,
    header_start: u32,
    header_count: u32,
    body_offset: u32,
    body_length: u32,
    content_length: u64,
    keep_alive: bool,
};

/// HTTP response data structure for SoA layout
pub const HttpResponseData = struct {
    request_id: u32,
    status_code: HttpStatus,
    status_message_offset: u32,
    status_message_length: u32,
    header_start: u32,
    header_count: u32,
    body_offset: u32,
    body_length: u32,
    content_length: u64,
    keep_alive: bool,
};

/// HTTP header data structure for SoA layout
pub const HttpHeaderData = struct {
    name_offset: u32,
    name_length: u32,
    value_offset: u32,
    value_length: u32,
    hash: u64,
};

/// Performance and debugging configuration
pub const PerformanceConfig = struct {
    pub const enable_profiling = true;
    pub const enable_statistics = true;
    pub const enable_connection_tracking = true;
    pub const enable_request_logging = true;
    pub const enable_simd_optimization = true;
    pub const enable_zero_copy = true;
};

/// Memory pool configuration
pub const MemoryConfig = struct {
    // Connection pool
    pub const connection_pool_size = DOD_CONSTANTS.MAX_CONNECTIONS * @sizeOf(ConnectionData);

    // Request pool
    pub const request_pool_size = DOD_CONSTANTS.MAX_HTTP_REQUESTS * @sizeOf(HttpRequestData);

    // Response pool
    pub const response_pool_size = DOD_CONSTANTS.MAX_HTTP_REQUESTS * @sizeOf(HttpResponseData);

    // Header pool
    pub const header_pool_size = DOD_CONSTANTS.MAX_HTTP_REQUESTS * DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST * @sizeOf(HttpHeaderData);

    // Buffer pools
    pub const total_buffer_size = DOD_CONSTANTS.NETWORK_BUFFER_POOL_SIZE;

    // Total memory requirement
    pub const total_memory_size = connection_pool_size + request_pool_size + response_pool_size +
        header_pool_size + total_buffer_size;
};
