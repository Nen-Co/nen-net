// Test-safe DOD configuration for large static arrays
// Reduces static memory allocation to prevent stack overflow during testing

const std = @import("std");

// Reduced DOD constants for testing
pub const TEST_DOD_CONSTANTS = struct {
    // Reduced sizes for testing (prevent stack overflow)
    pub const CACHE_LINE_SIZE = 64;
    pub const SIMD_ALIGNMENT = 32;
    pub const PAGE_SIZE = 4096;

    // Smaller pool sizes for testing
    pub const MAX_CONNECTIONS = 8; // Reduced from 8192
    pub const MAX_REQUESTS = 8; // Reduced from 8192
    pub const MAX_RESPONSES = 8; // Reduced from 8192
    pub const MAX_BUFFERS = 8; // Reduced from 1024
    pub const MAX_HEADERS = 8; // Reduced from 512
    pub const MAX_ROUTES = 8; // Reduced from 256

    // Smaller buffer sizes for testing
    pub const CONNECTION_BUFFER_SIZE = 1024; // Reduced from 65536
    pub const REQUEST_BUFFER_SIZE = 2048; // Reduced from 1048576
    pub const RESPONSE_BUFFER_SIZE = 2048; // Reduced from 1048576
    pub const HEADER_BUFFER_SIZE = 256; // Reduced from 8192

    // SIMD batch sizes (kept small for testing)
    pub const SIMD_NETWORK_BATCH = 4; // Reduced from 8
    pub const SIMD_HTTP_BATCH = 4; // Reduced from 8
    pub const SIMD_CONNECTION_BATCH = 4; // Reduced from 8
    pub const SIMD_BUFFER_BATCH = 4; // Reduced from 8
};

// Test configuration that can be used in place of production config
pub const TestDODConfig = struct {
    // Network configuration (reduced for testing)
    pub const network = struct {
        pub const max_connections: u32 = 8;
        pub const max_requests_per_connection: u32 = 8;
        pub const buffer_size: u32 = 1024;
        pub const timeout_ms: u32 = 1000;
        pub const enable_keep_alive: bool = false; // Simplified for testing
    };

    // HTTP configuration (reduced for testing)
    pub const http = struct {
        pub const max_headers: u32 = 8;
        pub const max_header_size: u32 = 256;
        pub const max_body_size: u32 = 1024;
        pub const max_url_size: u32 = 256;
        pub const enable_compression: bool = false; // Simplified for testing
    };

    // Memory management (heap-based for testing)
    pub const memory = struct {
        pub const enable_static_allocation: bool = false; // Use heap for testing
        pub const pool_size: u32 = 64 * 1024; // 64KB pool
        pub const alignment_size: u32 = 32;
        pub const enable_memory_tracking: bool = true;
    };

    // SIMD configuration (reduced for testing)
    pub const simd = struct {
        pub const enable_simd: bool = true;
        pub const vector_width: u32 = 4; // Reduced from 8
        pub const enable_vectorized_parsing: bool = true;
        pub const enable_vectorized_validation: bool = true;
    };

    // Batching configuration (reduced for testing)
    pub const batching = struct {
        pub const enable_batch_processing: bool = true;
        pub const batch_size: u32 = 4; // Reduced from 8
        pub const max_concurrent_batches: u32 = 2; // Reduced from 4
        pub const timeout_ms: u32 = 100;
    };
};

// Heap-based DOD layout for testing (avoids stack overflow)
pub fn createTestDODLayout(allocator: std.mem.Allocator) !*TestDODNetworkLayout {
    const layout = try allocator.create(TestDODNetworkLayout);
    layout.* = TestDODNetworkLayout.init();
    return layout;
}

pub const TestDODNetworkLayout = struct {
    // Connection data (small arrays for testing)
    connection_ids: [TEST_DOD_CONSTANTS.MAX_CONNECTIONS]u32,
    connection_states: [TEST_DOD_CONSTANTS.MAX_CONNECTIONS]u8,
    connection_active: [TEST_DOD_CONSTANTS.MAX_CONNECTIONS]bool,
    connection_timestamps: [TEST_DOD_CONSTANTS.MAX_CONNECTIONS]u64,

    // Request data (small arrays for testing)
    request_ids: [TEST_DOD_CONSTANTS.MAX_REQUESTS]u32,
    request_methods: [TEST_DOD_CONSTANTS.MAX_REQUESTS]u8,
    request_active: [TEST_DOD_CONSTANTS.MAX_REQUESTS]bool,
    request_sizes: [TEST_DOD_CONSTANTS.MAX_REQUESTS]u32,

    // Response data (small arrays for testing)
    response_ids: [TEST_DOD_CONSTANTS.MAX_RESPONSES]u32,
    response_status_codes: [TEST_DOD_CONSTANTS.MAX_RESPONSES]u16,
    response_active: [TEST_DOD_CONSTANTS.MAX_RESPONSES]bool,
    response_sizes: [TEST_DOD_CONSTANTS.MAX_RESPONSES]u32,

    // Counters
    connection_count: u32,
    request_count: u32,
    response_count: u32,

    pub fn init() TestDODNetworkLayout {
        return TestDODNetworkLayout{
            .connection_ids = [_]u32{0} ** TEST_DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_states = [_]u8{0} ** TEST_DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_active = [_]bool{false} ** TEST_DOD_CONSTANTS.MAX_CONNECTIONS,
            .connection_timestamps = [_]u64{0} ** TEST_DOD_CONSTANTS.MAX_CONNECTIONS,

            .request_ids = [_]u32{0} ** TEST_DOD_CONSTANTS.MAX_REQUESTS,
            .request_methods = [_]u8{0} ** TEST_DOD_CONSTANTS.MAX_REQUESTS,
            .request_active = [_]bool{false} ** TEST_DOD_CONSTANTS.MAX_REQUESTS,
            .request_sizes = [_]u32{0} ** TEST_DOD_CONSTANTS.MAX_REQUESTS,

            .response_ids = [_]u32{0} ** TEST_DOD_CONSTANTS.MAX_RESPONSES,
            .response_status_codes = [_]u16{0} ** TEST_DOD_CONSTANTS.MAX_RESPONSES,
            .response_active = [_]bool{false} ** TEST_DOD_CONSTANTS.MAX_RESPONSES,
            .response_sizes = [_]u32{0} ** TEST_DOD_CONSTANTS.MAX_RESPONSES,

            .connection_count = 0,
            .request_count = 0,
            .response_count = 0,
        };
    }

    pub fn addConnection(self: *TestDODNetworkLayout, connection_id: u32) !u32 {
        if (self.connection_count >= TEST_DOD_CONSTANTS.MAX_CONNECTIONS) {
            return error.ConnectionLimitExceeded;
        }

        const index = self.connection_count;
        self.connection_ids[index] = connection_id;
        self.connection_states[index] = 1; // Connected state
        self.connection_active[index] = true;
        self.connection_timestamps[index] = @intCast(std.time.nanoTimestamp());

        self.connection_count += 1;
        return index;
    }

    pub fn addRequest(self: *TestDODNetworkLayout, request_id: u32, method: u8, size: u32) !u32 {
        if (self.request_count >= TEST_DOD_CONSTANTS.MAX_REQUESTS) {
            return error.RequestLimitExceeded;
        }

        const index = self.request_count;
        self.request_ids[index] = request_id;
        self.request_methods[index] = method;
        self.request_active[index] = true;
        self.request_sizes[index] = size;

        self.request_count += 1;
        return index;
    }

    pub fn addResponse(self: *TestDODNetworkLayout, response_id: u32, status_code: u16, size: u32) !u32 {
        if (self.response_count >= TEST_DOD_CONSTANTS.MAX_RESPONSES) {
            return error.ResponseLimitExceeded;
        }

        const index = self.response_count;
        self.response_ids[index] = response_id;
        self.response_status_codes[index] = status_code;
        self.response_active[index] = true;
        self.response_sizes[index] = size;

        self.response_count += 1;
        return index;
    }

    pub fn getActiveConnections(self: *const TestDODNetworkLayout, buffer: []u32) u32 {
        var count: u32 = 0;
        for (0..self.connection_count) |i| {
            if (self.connection_active[i] and count < buffer.len) {
                buffer[count] = @intCast(i);
                count += 1;
            }
        }
        return count;
    }
};

// Test SIMD operations (reduced scope)
pub const TestSIMDOperations = struct {
    pub fn processConnectionsBatch(layout: *TestDODNetworkLayout, connection_indices: []const u32) u32 {
        var processed: u32 = 0;
        const batch_size = TEST_DOD_CONSTANTS.SIMD_CONNECTION_BATCH;

        var i: u32 = 0;
        while (i < connection_indices.len) {
            const current_batch_size = @min(batch_size, connection_indices.len - i);

            for (i..i + current_batch_size) |j| {
                const conn_idx = connection_indices[j];
                if (conn_idx < layout.connection_count and layout.connection_active[conn_idx]) {
                    // Process connection (placeholder)
                    processed += 1;
                }
            }

            i += current_batch_size;
        }

        return processed;
    }

    pub fn validateRequestsBatch(layout: *const TestDODNetworkLayout, validation_results: []bool) u32 {
        var validated: u32 = 0;
        const batch_size = TEST_DOD_CONSTANTS.SIMD_HTTP_BATCH;
        const max_results = @min(validation_results.len, layout.request_count);

        var i: u32 = 0;
        while (i < layout.request_count and validated < max_results) {
            const current_batch_size = @min(batch_size, layout.request_count - i);

            for (i..i + current_batch_size) |j| {
                if (validated < max_results) {
                    validation_results[validated] = layout.request_active[j] and
                        layout.request_methods[j] > 0 and
                        layout.request_sizes[j] > 0;
                    validated += 1;
                }
            }

            i += current_batch_size;
        }

        return validated;
    }
};
