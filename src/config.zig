// Nen Net Library - Configuration
// Centralized configuration for static memory allocation

// Server configuration
pub const ServerConfig = struct {
    port: u16 = 8080,
    max_connections: u32 = 1000,
    request_buffer_size: usize = 8192,        // 8KB request buffer
    response_buffer_size: usize = 16384,      // 16KB response buffer
    connection_timeout_ms: u32 = 30000,       // 30 seconds
    keep_alive_timeout_ms: u32 = 60000,      // 60 seconds
    max_request_size: usize = 1048576,        // 1MB max request
    enable_compression: bool = true,
    enable_tls: bool = false,
    worker_threads: u32 = 4,
    accept_backlog: u32 = 128,
    tcp_nodelay: bool = true,
    reuse_address: bool = true,
    reuse_port: bool = false,
};

// Client configuration
pub const ClientConfig = struct {
    host: []const u8 = "localhost",
    port: u16 = 8080,
    buffer_size: usize = 4096,               // 4KB client buffer
    connection_timeout_ms: u32 = 10000,      // 10 seconds
    read_timeout_ms: u32 = 30000,            // 30 seconds
    write_timeout_ms: u32 = 30000,           // 30 seconds
    keep_alive: bool = true,
    max_redirects: u32 = 5,
    user_agent: []const u8 = "Nen-Net/1.0",
    enable_compression: bool = true,
    enable_tls: bool = false,
};

// WebSocket configuration
pub const WebSocketConfig = struct {
    port: u16 = 8081,
    max_connections: u32 = 100,
    buffer_size: usize = 8192,               // 8KB WebSocket buffer
    ping_interval_ms: u32 = 30000,           // 30 seconds
    pong_timeout_ms: u32 = 10000,            // 10 seconds
    max_frame_size: usize = 1048576,         // 1MB max frame
    enable_compression: bool = true,
    enable_binary_messages: bool = true,
    enable_text_messages: bool = true,
};

// Default values for quick access
pub const default_port: u16 = 8080;
pub const max_connections: u32 = 1000;
pub const request_buffer_size: usize = 8192;
pub const response_buffer_size: usize = 16384;
pub const client_buffer_size: usize = 4096;
pub const websocket_buffer_size: usize = 8192;

// Buffer sizes for different use cases
pub const small_buffer_size = 1024;          // 1KB - small operations
pub const medium_buffer_size = 8192;         // 8KB - medium operations
pub const large_buffer_size = 65536;         // 64KB - large operations
pub const huge_buffer_size = 1048576;        // 1MB - huge operations

// Connection pool sizes
pub const connection_pool_size = 1000;       // Default connection pool
pub const small_pool_size = 100;             // Small server pool
pub const medium_pool_size = 1000;           // Medium server pool
pub const large_pool_size = 10000;           // Large server pool
pub const huge_pool_size = 100000;           // Huge server pool

// Timeout values
pub const short_timeout_ms = 1000;           // 1 second
pub const medium_timeout_ms = 10000;         // 10 seconds
pub const long_timeout_ms = 60000;           // 60 seconds
pub const very_long_timeout_ms = 300000;     // 5 minutes

// Performance thresholds
pub const min_throughput_requests_s = 1000;  // Minimum 1K requests/second
pub const max_latency_ms = 100;              // Maximum 100ms latency
pub const max_memory_usage_mb = 1024;        // Maximum 1GB memory usage
pub const max_cpu_usage_percent = 80.0;      // Maximum 80% CPU usage

// HTTP specific settings
pub const max_http_headers = 100;            // Maximum HTTP headers
pub const max_http_body_size = 104857600;    // Maximum HTTP body (100MB)
pub const max_url_length = 2048;             // Maximum URL length
pub const max_method_length = 16;            // Maximum HTTP method length
pub const max_status_line_length = 256;      // Maximum status line length

// TCP specific settings
pub const tcp_send_buffer_size = 65536;      // TCP send buffer size
pub const tcp_receive_buffer_size = 65536;   // TCP receive buffer size
pub const tcp_keep_alive_interval = 30;      // TCP keep-alive interval
pub const tcp_keep_alive_probes = 3;         // TCP keep-alive probes
pub const tcp_keep_alive_time = 60;          // TCP keep-alive time

// WebSocket specific settings
pub const websocket_max_message_size = 1048576;  // 1MB max message
pub const websocket_max_frame_size = 1048576;    // 1MB max frame
pub const websocket_handshake_timeout_ms = 5000; // 5 seconds handshake timeout
pub const websocket_close_timeout_ms = 5000;     // 5 seconds close timeout

// Batching configuration - Following nen-db patterns
pub const batching = struct {
    // Connection batching
    pub const connection_batch_size = 100;       // Batch connection operations
    pub const connection_sync_interval = 50;     // Sync every 50 operations
    
    // Request batching
    pub const request_batch_size = 1000;         // Batch request processing
    pub const request_sync_interval = 100;       // Sync every 100 requests
    
    // Response batching
    pub const response_batch_size = 1000;        // Batch response sending
    pub const response_sync_interval = 100;      // Sync every 100 responses
    
    // WebSocket batching
    pub const websocket_batch_size = 500;        // Batch WebSocket operations
    pub const websocket_sync_interval = 50;      // Sync every 50 operations
};

// Memory management
pub const memory_pool_size = 16777216;       // 16MB memory pool
pub const max_memory_usage = 1073741824;     // 1GB maximum memory usage
pub const memory_cleanup_threshold = 0.8;    // Cleanup when 80% full
pub const memory_fragmentation_threshold = 0.3; // Defragment when 30% fragmented

// Logging and debugging
pub const enable_performance_logging = true;  // Enable performance logging
pub const enable_memory_logging = true;      // Enable memory usage logging
pub const enable_connection_logging = true;   // Enable connection logging
pub const enable_request_logging = true;      // Enable request logging
pub const enable_error_logging = true;        // Enable error logging

// Security settings
pub const max_request_rate = 1000;           // Maximum requests per second per IP
pub const max_connections_per_ip = 100;      // Maximum connections per IP
pub const enable_rate_limiting = true;       // Enable rate limiting
pub const enable_ip_blacklisting = true;     // Enable IP blacklisting
pub const blacklist_threshold = 1000;        // Blacklist after 1000 violations
