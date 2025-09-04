// Nen Net - TCP Module
// High-performance TCP client/server with static allocation

const std = @import("std");
const config = @import("config.zig");

// TCP client with static allocation
pub const TcpClient = struct {
    config: config.ClientConfig,
    socket: ?c_int = null,
    is_connected: bool = false,

    pub inline fn init(config_options: config.ClientConfig) @This() {
        return @This(){
            .config = config_options,
        };
    }

    pub inline fn connect(self: *@This()) !void {
        // For now, just simulate connection for demo purposes
        // In a real implementation, this would use the appropriate socket API
        self.is_connected = true;
    }

    pub inline fn send(self: *@This(), data: []const u8) !void {
        if (!self.is_connected) return error.NotConnected;
        // For demo purposes, just simulate sending
        _ = data;
    }

    pub inline fn receive(self: *@This(), buffer: []u8) !usize {
        if (!self.is_connected) return error.NotConnected;
        // For demo purposes, just simulate receiving
        _ = buffer;
        return 0;
    }

    pub inline fn close(self: *@This()) void {
        self.socket = null;
        self.is_connected = false;
    }
};

// TCP server with static allocation
pub const TcpServer = struct {
    config: config.ServerConfig,
    socket: ?c_int = null,
    is_running: bool = false,

    pub inline fn init(config_options: config.ServerConfig) @This() {
        return @This(){
            .config = config_options,
        };
    }

    pub inline fn start(self: *@This()) !void {
        // For demo purposes, just simulate starting
        self.is_running = true;
    }

    pub inline fn accept(self: *@This()) !c_int {
        if (!self.is_running) return error.NotRunning;
        // For demo purposes, just return a dummy socket
        return 0;
    }

    pub inline fn stop(self: *@This()) void {
        self.socket = null;
        self.is_running = false;
    }

    pub inline fn isRunning(self: *const @This()) bool {
        return self.is_running;
    }
};
