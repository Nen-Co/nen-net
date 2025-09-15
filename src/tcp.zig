// Nen Net - High-Performance TCP Module
// DOD-based TCP server with Zig speed optimizations and static allocation
// Now uses nen-io for low-level network operations

const std = @import("std");
const config = @import("config.zig");
const nen_io = @import("nen-io");
const builtin = @import("builtin");

// Use nen-io for network operations
const NetworkSocket = nen_io.NetworkSocket;
const parseAddress = nen_io.network.parseAddress;

// DOD Connection Pool - Struct of Arrays layout for cache efficiency
pub const ConnectionPool = struct {
    // Hot data (frequently accessed) - packed together for cache efficiency
    sockets: [4096]NetworkSocket,
    states: [4096]ConnectionState,
    last_activity: [4096]u64,
    buffer_indices: [4096]u16,

    // Cold data (less frequently accessed)
    client_addrs: [4096]std.net.Address,
    connection_ids: [4096]u32,

    // Pool management
    active_count: u32,
    free_list: [4096]u16,
    free_count: u16,
    next_id: u32,

    // Pre-allocated buffers (zero-copy operations)
    read_buffers: [4096][8192]u8,
    write_buffers: [4096][8192]u8,

    pub const ConnectionState = enum(u8) {
        free = 0,
        connected = 1,
        reading = 2,
        writing = 3,
        closing = 4,
    };

    pub inline fn init() @This() {
        var pool = @This(){
            .sockets = undefined,
            .states = [_]ConnectionState{.free} ** 4096,
            .last_activity = [_]u64{0} ** 4096,
            .buffer_indices = [_]u16{0} ** 4096,
            .client_addrs = [_]std.net.Address{undefined} ** 4096,
            .connection_ids = [_]u32{0} ** 4096,
            .active_count = 0,
            .free_list = undefined,
            .free_count = 4096,
            .next_id = 1,
            .read_buffers = [_][8192]u8{[_]u8{0} ** 8192} ** 4096,
            .write_buffers = [_][8192]u8{[_]u8{0} ** 8192} ** 4096,
        };

        // Initialize free list
        for (0..4096) |i| {
            pool.free_list[i] = @intCast(i);
        }

        return pool;
    }

    pub inline fn acquire(self: *@This()) ?u16 {
        if (self.free_count == 0) return null;

        self.free_count -= 1;
        const slot = self.free_list[self.free_count];

        // Reset slot data (branchless where possible)
        self.states[slot] = .connected;
        self.last_activity[slot] = @intCast(std.time.nanoTimestamp());
        self.connection_ids[slot] = self.next_id;
        self.next_id += 1;
        self.active_count += 1;

        return slot;
    }

    pub inline fn release(self: *@This(), slot: u16) void {
        self.states[slot] = .free;
        self.free_list[self.free_count] = slot;
        self.free_count += 1;
        self.active_count -= 1;
    }

    pub inline fn getActiveConnections(self: *const @This()) u32 {
        return self.active_count;
    }
};

// High-performance TCP server with DOD and epoll/kqueue
pub const TcpServer = struct {
    config: config.ServerConfig,
    listen_socket: NetworkSocket,
    connection_pool: ConnectionPool,
    is_running: bool,

    // Platform-specific event system
    event_fd: if (builtin.os.tag == .linux) i32 else if (builtin.os.tag == .macos) i32 else void,
    events: if (builtin.os.tag == .linux) [1024]std.os.linux.epoll_event else [1024]u8,

    pub inline fn init(config_options: config.ServerConfig) !@This() {
        // Create listen socket using nen-io
        var listen_socket = try NetworkSocket.createTcp();
        errdefer listen_socket.close();

        // Configure socket
        try listen_socket.configure(.{
            .reuse_addr = true,
            .tcp_nodelay = true,
            .non_blocking = true,
            .keep_alive = true,
        });

        // Create event system (epoll on Linux, kqueue on macOS, nothing else supported)
        const event_fd = if (builtin.os.tag == .linux)
            try std.posix.epoll_create1(std.os.linux.EPOLL.CLOEXEC)
        else if (builtin.os.tag == .macos)
            -1 // Placeholder for kqueue implementation
        else {};

        return @This(){
            .config = config_options,
            .listen_socket = listen_socket,
            .connection_pool = ConnectionPool.init(),
            .is_running = false,
            .event_fd = event_fd,
            .events = std.mem.zeroes(@TypeOf(@as(@This(), undefined).events)),
        };
    }

    pub inline fn bind(self: *@This()) !void {
        const addr = try parseAddress("0.0.0.0", self.config.port);
        try self.listen_socket.bind(addr);
        try self.listen_socket.listen(128); // High backlog for performance

        // Add listen socket to event system
        if (builtin.os.tag == .linux) {
            var event = std.os.linux.epoll_event{
                .events = std.os.linux.EPOLL.IN | std.os.linux.EPOLL.ET,
                .data = .{ .fd = self.listen_socket.getFd() },
            };
            try std.posix.epoll_ctl(self.event_fd, std.os.linux.EPOLL.CTL_ADD, self.listen_socket.getFd(), &event);
        }
    }

    pub inline fn start(self: *@This()) !void {
        try self.bind();
        self.is_running = true;

        while (self.is_running) {
            try self.eventLoop();
        }
    }

    // High-performance event loop with minimal allocations
    inline fn eventLoop(self: *@This()) !void {
        const event_count = if (builtin.os.tag == .linux)
            std.posix.epoll_wait(self.event_fd, &self.events, 10) // 10ms timeout
        else if (builtin.os.tag == .macos) blk: {
            // Simple fallback for macOS - just try to accept connections
            // TODO: Implement kqueue for proper event handling
            self.acceptConnections() catch {};
            std.Thread.sleep(10 * std.time.ns_per_ms); // 10ms sleep
            break :blk 0;
        } else 0;

        for (0..@intCast(event_count)) |i| {
            if (builtin.os.tag == .linux) {
                const event = &self.events[i];
                if (event.data.fd == self.listen_socket) {
                    try self.acceptConnections();
                } else {
                    try self.handleClientEvent(@intCast(event.data.fd));
                }
            }
        }
    }

    inline fn acceptConnections(self: *@This()) !void {
        // Accept multiple connections in a tight loop (edge-triggered)
        while (true) {
            const result = self.listen_socket.accept() catch |err| {
                if (err == error.WouldBlock) break; // No more connections
                return err;
            };

            const client_socket = result.socket;
            const client_addr = result.address;

            // Acquire connection slot
            const slot = self.connection_pool.acquire() orelse {
                client_socket.close();
                continue; // Pool exhausted
            };

            // Store connection data
            self.connection_pool.sockets[slot] = client_socket;
            self.connection_pool.client_addrs[slot] = client_addr;

            // Add to event system
            if (builtin.os.tag == .linux) {
                var event = std.os.linux.epoll_event{
                    .events = std.os.linux.EPOLL.IN | std.os.linux.EPOLL.ET,
                    .data = .{ .fd = client_socket.getFd() },
                };
                try std.posix.epoll_ctl(self.event_fd, std.os.linux.EPOLL.CTL_ADD, client_socket.getFd(), &event);
            }
        }
    }

    inline fn handleClientEvent(self: *@This(), socket_fd: std.posix.socket_t) !void {
        // Find connection slot (could be optimized with a hash map for many connections)
        var slot: u16 = 0;
        while (slot < 4096) : (slot += 1) {
            if (self.connection_pool.states[slot] == .connected and
                self.connection_pool.sockets[slot].getFd() == socket_fd) break;
        } else return; // Connection not found

        const bytes_read = self.connection_pool.sockets[slot].receive(&self.connection_pool.read_buffers[slot]) catch |err| {
            if (err == error.WouldBlock) return;
            self.closeConnection(slot);
            return;
        };

        if (bytes_read == 0) {
            self.closeConnection(slot);
            return;
        }

        // Update activity timestamp (cast i128 to u64 for cross-platform compatibility)
        self.connection_pool.last_activity[slot] = @intCast(std.time.nanoTimestamp());

        // Process the data (this would call your NenDB protocol handler)
        try self.processMessage(slot, self.connection_pool.read_buffers[slot][0..bytes_read]);
    }

    // NenDB protocol processing - will be implemented
    inline fn processMessage(self: *@This(), slot: u16, data: []const u8) !void {
        // This is where NenDB protocol messages would be decoded and processed
        // For now, echo back the data as a simple test
        const socket = &self.connection_pool.sockets[slot];
        _ = try socket.send("ECHO: ");
        _ = try socket.send(data);
    }

    inline fn closeConnection(self: *@This(), slot: u16) void {
        const socket = &self.connection_pool.sockets[slot];
        socket.close();
        self.connection_pool.release(slot);
    }

    pub inline fn stop(self: *@This()) void {
        self.is_running = false;
    }

    pub inline fn getStats(self: *const @This()) ConnectionStats {
        return ConnectionStats{
            .active_connections = self.connection_pool.getActiveConnections(),
            .total_slots = 4096,
            .free_slots = self.connection_pool.free_count,
        };
    }

    pub const ConnectionStats = struct {
        active_connections: u32,
        total_slots: u16,
        free_slots: u16,
    };
};

// TCP client with connection pooling and reuse
pub const TcpClient = struct {
    config: config.ClientConfig,
    socket: ?NetworkSocket = null,
    is_connected: bool = false,

    pub inline fn init(config_options: config.ClientConfig) @This() {
        return @This(){
            .config = config_options,
        };
    }

    pub inline fn connect(self: *@This(), address: []const u8, port: u16) !void {
        const addr = try parseAddress(address, port);
        self.socket = try NetworkSocket.createTcp();

        // Configure socket
        try self.socket.?.configure(.{
            .reuse_addr = true,
            .tcp_nodelay = true,
            .non_blocking = true,
            .keep_alive = true,
        });

        try self.socket.?.connect(addr);
        self.is_connected = true;
    }

    pub inline fn send(self: *@This(), data: []const u8) !usize {
        if (!self.is_connected or self.socket == null) return error.NotConnected;
        return try self.socket.?.send(data);
    }

    pub inline fn receive(self: *@This(), buffer: []u8) !usize {
        if (!self.is_connected or self.socket == null) return error.NotConnected;
        return try self.socket.?.receive(buffer);
    }

    pub inline fn close(self: *@This()) void {
        if (self.socket) |*socket| {
            socket.close();
        }
        self.socket = null;
        self.is_connected = false;
    }
};
