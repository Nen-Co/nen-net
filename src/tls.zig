// Nen Net - TLS Module (Scaffold)
// Placeholder API returning TLSNotSupported to unblock integration and CI

const std = @import("std");
const config = @import("config.zig");

pub const TlsConfig = struct {
    enable: bool = false,
    cert_path: []const u8 = "",
    key_path: []const u8 = "",
};

pub const TlsContext = struct {
    cfg: TlsConfig,

    pub inline fn init(cfg: TlsConfig) !TlsContext {
        _ = cfg;
        return error.TLSNotSupported;
    }

    pub inline fn wrapServer(self: *TlsContext, fd: i32) !void {
        _ = self;
        _ = fd;
        return error.TLSNotSupported;
    }

    pub inline fn wrapClient(self: *TlsContext, fd: i32) !void {
        _ = self;
        _ = fd;
        return error.TLSNotSupported;
    }
};


