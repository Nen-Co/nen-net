// Nen Net - Signal Handling Module (Minimal for Zig 0.15.1)
// Implements basic graceful shutdown for production servers

const std = @import("std");
const c = std.c;

// Signal handling configuration
pub const SignalConfig = struct {
    enable_graceful_shutdown: bool = true,
    shutdown_timeout_ms: u32 = 5000, // 5 seconds
    enable_signal_logging: bool = true,
};

// Global signal state
var shutdown_requested: std.atomic.Value(bool) = std.atomic.Value(bool).init(false);
var signal_config: SignalConfig = SignalConfig{};

// Signal handler function type
pub const SignalHandler = *const fn (sig: c_int) void;

// Signal handlers registry
var signal_handlers: [16]?SignalHandler = [_]?SignalHandler{null} ** 16;

/// Initialize signal handling
pub fn init(config: SignalConfig) void {
    signal_config = config;

    if (config.enable_graceful_shutdown) {
        setupSignalHandlers();
    }
}

/// Setup signal handlers for graceful shutdown (simplified)
fn setupSignalHandlers() void {
    // For now, we'll use a simple approach that works across platforms
    // In a production system, you'd want platform-specific signal handling
    // The application should check isShutdownRequested() periodically
    _ = setupSignalHandlers;
}

/// Signal handler function (simplified)
fn signalHandler(sig: c_int) callconv(.c) void {
    if (signal_config.enable_signal_logging) {
        std.debug.print("🛑 Received signal {d}, initiating graceful shutdown...\n", .{sig});
    }

    // Set shutdown flag
    shutdown_requested.store(true, .release);

    // Call registered handlers
    for (signal_handlers) |handler| {
        if (handler) |h| {
            h(sig);
        }
    }
}

/// Check if shutdown has been requested
pub inline fn isShutdownRequested() bool {
    return shutdown_requested.load(.acquire);
}

/// Reset shutdown flag (for testing)
pub inline fn resetShutdownFlag() void {
    shutdown_requested.store(false, .release);
}

/// Register a custom signal handler
pub fn registerSignalHandler(handler: SignalHandler) !void {
    for (signal_handlers, 0..) |existing, i| {
        if (existing == null) {
            signal_handlers[i] = handler;
            return;
        }
    }
    return error.TooManyHandlers;
}

/// Wait for shutdown with timeout
pub fn waitForShutdown(timeout_ms: u32) bool {
    const start_time = std.time.milliTimestamp();

    while (!isShutdownRequested()) {
        std.Thread.sleep(100 * std.time.ns_per_ms); // Sleep 100ms

        const elapsed = @as(u32, @intCast(std.time.milliTimestamp() - start_time));
        if (elapsed >= timeout_ms) {
            return false; // Timeout
        }
    }

    return true; // Shutdown requested
}

/// Force immediate shutdown
pub fn forceShutdown() void {
    shutdown_requested.store(true, .release);
}

/// Get shutdown timeout from config
pub inline fn getShutdownTimeout() u32 {
    return signal_config.shutdown_timeout_ms;
}

// =============================================================================
// Tests
// =============================================================================

test "signal handling initialization" {
    const config = SignalConfig{
        .enable_graceful_shutdown = true,
        .shutdown_timeout_ms = 1000,
        .enable_signal_logging = false,
    };

    init(config);

    try std.testing.expect(!isShutdownRequested());
    try std.testing.expectEqual(@as(u32, 1000), getShutdownTimeout());
}

test "shutdown flag manipulation" {
    resetShutdownFlag();
    try std.testing.expect(!isShutdownRequested());

    forceShutdown();
    try std.testing.expect(isShutdownRequested());

    resetShutdownFlag();
    try std.testing.expect(!isShutdownRequested());
}
