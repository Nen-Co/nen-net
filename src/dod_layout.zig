// Nen Net Library - Data-Oriented Design Layout
// SoA (Struct of Arrays) layout for high-performance network operations

const std = @import("std");
const dod_config = @import("dod_config.zig");

/// Main DOD layout for network operations
pub const DODNetworkLayout = struct {
    const Self = @This();
    
    // === CONNECTION ARRAYS (SoA) ===
    // Connection metadata separated for cache efficiency
    connection_socket_fds: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS]i32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    connection_states: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS]dod_config.ConnectionState align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    connection_protocols: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS]dod_config.ProtocolType align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    connection_local_ports: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS]u16 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    connection_remote_ports: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS]u16 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    connection_bytes_read: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS]u64 align(dod_config.DOD_CONSTANTS.SIMD_ALIGNMENT),
    connection_bytes_written: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS]u64 align(dod_config.DOD_CONSTANTS.SIMD_ALIGNMENT),
    connection_last_activity: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS]u64 align(dod_config.DOD_CONSTANTS.SIMD_ALIGNMENT),
    connection_timeouts: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    connection_pipeline_depths: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS]u8 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    connection_active: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS]bool align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    
    // Connection addresses (IPv4/IPv6)
    connection_local_addresses: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS][16]u8 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    connection_remote_addresses: [dod_config.DOD_CONSTANTS.MAX_CONNECTIONS][16]u8 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    
    // === HTTP REQUEST ARRAYS (SoA) ===
    // HTTP requests organized by component for efficient processing
    request_connection_ids: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    request_methods: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]dod_config.HttpMethod align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    request_url_offsets: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    request_url_lengths: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    request_version_offsets: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    request_version_lengths: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    request_header_starts: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    request_header_counts: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    request_body_offsets: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    request_body_lengths: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    request_content_lengths: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u64 align(dod_config.DOD_CONSTANTS.SIMD_ALIGNMENT),
    request_keep_alive: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]bool align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    request_active: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]bool align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    
    // === HTTP RESPONSE ARRAYS (SoA) ===
    // HTTP responses organized for efficient generation
    response_request_ids: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    response_status_codes: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]dod_config.HttpStatus align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    response_status_message_offsets: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    response_status_message_lengths: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    response_header_starts: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    response_header_counts: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    response_body_offsets: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    response_body_lengths: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    response_content_lengths: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]u64 align(dod_config.DOD_CONSTANTS.SIMD_ALIGNMENT),
    response_keep_alive: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]bool align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    response_active: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS]bool align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    
    // === HTTP HEADER ARRAYS (SoA) ===
    // Headers organized for efficient parsing and generation
    header_name_offsets: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS * dod_config.DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    header_name_lengths: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS * dod_config.DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    header_value_offsets: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS * dod_config.DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    header_value_lengths: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS * dod_config.DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST]u32 align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    header_hashes: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS * dod_config.DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST]u64 align(dod_config.DOD_CONSTANTS.SIMD_ALIGNMENT),
    header_active: [dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS * dod_config.DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST]bool align(dod_config.DOD_CONSTANTS.CACHE_LINE_SIZE),
    
    // === BUFFER POOLS ===
    // Network data storage with efficient allocation
    network_buffer_pool: [dod_config.DOD_CONSTANTS.NETWORK_BUFFER_POOL_SIZE]u8 align(dod_config.DOD_CONSTANTS.SIMD_ALIGNMENT),
    buffer_pool_position: u32,
    
    // Request/response data buffers
    request_data_buffer: [dod_config.DOD_CONSTANTS.REQUEST_BUFFER_SIZE * 64]u8 align(dod_config.DOD_CONSTANTS.SIMD_ALIGNMENT),
    response_data_buffer: [dod_config.DOD_CONSTANTS.RESPONSE_BUFFER_SIZE * 64]u8 align(dod_config.DOD_CONSTANTS.SIMD_ALIGNMENT),
    
    // === COUNTERS ===
    connection_count: u32,
    request_count: u32,
    response_count: u32,
    header_count: u32,
    
    // === STATISTICS ===
    total_requests_processed: u64,
    total_responses_sent: u64,
    total_bytes_received: u64,
    total_bytes_sent: u64,
    average_request_time_ns: u64,
    active_connections: u32,
    
    /// Initialize DOD network layout
    pub fn init() Self {
        return Self{
            // Initialize connection arrays
            .connection_socket_fds = [_]i32{-1} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_states = [_]dod_config.ConnectionState{.inactive} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_protocols = [_]dod_config.ProtocolType{.unknown} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_local_ports = [_]u16{0} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_remote_ports = [_]u16{0} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_bytes_read = [_]u64{0} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_bytes_written = [_]u64{0} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_last_activity = [_]u64{0} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_timeouts = [_]u32{dod_config.DOD_CONSTANTS.CONNECTION_TIMEOUT_MS} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_pipeline_depths = [_]u8{0} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_active = [_]bool{false} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            
            // Initialize addresses
            .connection_local_addresses = [_][16]u8{[_]u8{0} ** 16} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_remote_addresses = [_][16]u8{[_]u8{0} ** 16} ** dod_config.DOD_CONSTANTS.MAX_CONNECTIONS,
            
            // Initialize request arrays
            .request_connection_ids = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .request_methods = [_]dod_config.HttpMethod{.unknown} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .request_url_offsets = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .request_url_lengths = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .request_version_offsets = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .request_version_lengths = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .request_header_starts = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .request_header_counts = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .request_body_offsets = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .request_body_lengths = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .request_content_lengths = [_]u64{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .request_keep_alive = [_]bool{false} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .request_active = [_]bool{false} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            
            // Initialize response arrays
            .response_request_ids = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .response_status_codes = [_]dod_config.HttpStatus{.unknown} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .response_status_message_offsets = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .response_status_message_lengths = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .response_header_starts = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .response_header_counts = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .response_body_offsets = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .response_body_lengths = [_]u32{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .response_content_lengths = [_]u64{0} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .response_keep_alive = [_]bool{false} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            .response_active = [_]bool{false} ** dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS,
            
            // Initialize header arrays
            .header_name_offsets = [_]u32{0} ** (dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS * dod_config.DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST),
            .header_name_lengths = [_]u32{0} ** (dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS * dod_config.DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST),
            .header_value_offsets = [_]u32{0} ** (dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS * dod_config.DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST),
            .header_value_lengths = [_]u32{0} ** (dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS * dod_config.DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST),
            .header_hashes = [_]u64{0} ** (dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS * dod_config.DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST),
            .header_active = [_]bool{false} ** (dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS * dod_config.DOD_CONSTANTS.MAX_HEADERS_PER_REQUEST),
            
            // Initialize buffers
            .network_buffer_pool = [_]u8{0} ** dod_config.DOD_CONSTANTS.NETWORK_BUFFER_POOL_SIZE,
            .buffer_pool_position = 0,
            .request_data_buffer = [_]u8{0} ** (dod_config.DOD_CONSTANTS.REQUEST_BUFFER_SIZE * 64),
            .response_data_buffer = [_]u8{0} ** (dod_config.DOD_CONSTANTS.RESPONSE_BUFFER_SIZE * 64),
            
            // Initialize counters
            .connection_count = 0,
            .request_count = 0,
            .response_count = 0,
            .header_count = 0,
            
            // Initialize statistics
            .total_requests_processed = 0,
            .total_responses_sent = 0,
            .total_bytes_received = 0,
            .total_bytes_sent = 0,
            .average_request_time_ns = 0,
            .active_connections = 0,
        };
    }
    
    /// Reset layout for reuse
    pub inline fn reset(self: *Self) void {
        // Reset counters
        self.connection_count = 0;
        self.request_count = 0;
        self.response_count = 0;
        self.header_count = 0;
        self.buffer_pool_position = 0;
        self.active_connections = 0;
        
        // Reset statistics
        self.total_requests_processed = 0;
        self.total_responses_sent = 0;
        self.total_bytes_received = 0;
        self.total_bytes_sent = 0;
        self.average_request_time_ns = 0;
        
        // Clear active flags (more efficient than clearing all data)
        @memset(&self.connection_active, false);
        @memset(&self.request_active, false);
        @memset(&self.response_active, false);
        @memset(&self.header_active, false);
    }
    
    /// Add a new connection
    pub inline fn add_connection(
        self: *Self,
        socket_fd: i32,
        protocol: dod_config.ProtocolType,
        local_port: u16,
        remote_port: u16
    ) !u32 {
        if (self.connection_count >= dod_config.DOD_CONSTANTS.MAX_CONNECTIONS) {
            return error.TooManyConnections;
        }
        
        const index = self.connection_count;
        self.connection_socket_fds[index] = socket_fd;
        self.connection_states[index] = .connected;
        self.connection_protocols[index] = protocol;
        self.connection_local_ports[index] = local_port;
        self.connection_remote_ports[index] = remote_port;
        self.connection_bytes_read[index] = 0;
        self.connection_bytes_written[index] = 0;
        self.connection_last_activity[index] = @as(u64, @intCast(std.time.milliTimestamp()));
        self.connection_timeouts[index] = dod_config.DOD_CONSTANTS.CONNECTION_TIMEOUT_MS;
        self.connection_pipeline_depths[index] = 0;
        self.connection_active[index] = true;
        
        self.connection_count += 1;
        self.active_connections += 1;
        return index;
    }
    
    /// Add a new HTTP request
    pub inline fn add_request(
        self: *Self,
        connection_id: u32,
        method: dod_config.HttpMethod
    ) !u32 {
        if (self.request_count >= dod_config.DOD_CONSTANTS.MAX_HTTP_REQUESTS) {
            return error.TooManyRequests;
        }
        
        const index = self.request_count;
        self.request_connection_ids[index] = connection_id;
        self.request_methods[index] = method;
        self.request_url_offsets[index] = 0;
        self.request_url_lengths[index] = 0;
        self.request_version_offsets[index] = 0;
        self.request_version_lengths[index] = 0;
        self.request_header_starts[index] = self.header_count;
        self.request_header_counts[index] = 0;
        self.request_body_offsets[index] = 0;
        self.request_body_lengths[index] = 0;
        self.request_content_lengths[index] = 0;
        self.request_keep_alive[index] = false;
        self.request_active[index] = true;
        
        self.request_count += 1;
        return index;
    }
    
    /// Allocate buffer space
    pub inline fn allocate_buffer(self: *Self, size: u32) !u32 {
        if (self.buffer_pool_position + size >= dod_config.DOD_CONSTANTS.NETWORK_BUFFER_POOL_SIZE) {
            return error.BufferPoolFull;
        }
        
        const offset = self.buffer_pool_position;
        self.buffer_pool_position += size;
        return offset;
    }
    
    /// Get statistics
    pub inline fn get_stats(self: *const Self) struct {
        connections: u32,
        requests: u32,
        responses: u32,
        headers: u32,
        active_connections: u32,
        buffer_pool_used: u32,
        total_requests: u64,
        total_responses: u64,
        total_bytes_rx: u64,
        total_bytes_tx: u64,
    } {
        return .{
            .connections = self.connection_count,
            .requests = self.request_count,
            .responses = self.response_count,
            .headers = self.header_count,
            .active_connections = self.active_connections,
            .buffer_pool_used = self.buffer_pool_position,
            .total_requests = self.total_requests_processed,
            .total_responses = self.total_responses_sent,
            .total_bytes_rx = self.total_bytes_received,
            .total_bytes_tx = self.total_bytes_sent,
        };
    }
};

/// Global DOD network layout instance
var global_network_layout: DODNetworkLayout = DODNetworkLayout.init();

/// Get global network layout instance
pub inline fn get_global_layout() *DODNetworkLayout {
    return &global_network_layout;
}
