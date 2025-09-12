// Simple test for DOD Network
const std = @import("std");
const net = @import("lib.zig");

test "DOD Network basic initialization" {
    const layout = net.DODNetworkLayout.init();
    
    try std.testing.expect(layout.connection_count == 0);
    try std.testing.expect(layout.request_count == 0);
    try std.testing.expect(layout.buffer_pool_position == 0);
    
    std.debug.print("DOD Network layout initialized successfully\n", .{});
}
