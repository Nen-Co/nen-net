// Test DOD Network implementation
const std = @import("std");
const net = @import("lib.zig");

test "DOD Network layout initialization" {
    var layout = net.DODNetworkLayout.init();
    
    const stats = layout.get_stats();
    std.debug.print("\nDOD Network Layout Stats:\n", .{});
    std.debug.print("  Connections: {d}\n", .{stats.connections});
    std.debug.print("  Requests: {d}\n", .{stats.requests});
    std.debug.print("  Responses: {d}\n", .{stats.responses});
    std.debug.print("  Headers: {d}\n", .{stats.headers});
    std.debug.print("  Buffer pool used: {d} bytes\n", .{stats.buffer_pool_used});
    
    // Basic validation
    try std.testing.expect(stats.connections == 0);
    try std.testing.expect(stats.requests == 0);
    try std.testing.expect(stats.buffer_pool_used == 0);
}

test "DOD Network connection management" {
    var layout = net.DODNetworkLayout.init();
    
    // Add a test connection
    const conn_id = try layout.add_connection(123, .http_1_1, 8080, 3000);
    
    const stats = layout.get_stats();
    std.debug.print("\nConnection Management Stats:\n", .{});
    std.debug.print("  Connection ID: {d}\n", .{conn_id});
    std.debug.print("  Active connections: {d}\n", .{stats.active_connections});
    std.debug.print("  Socket FD: {d}\n", .{layout.connection_socket_fds[conn_id]});
    std.debug.print("  Protocol: {s}\n", .{@tagName(layout.connection_protocols[conn_id])});
    
    try std.testing.expect(conn_id == 0);
    try std.testing.expect(stats.active_connections == 1);
    try std.testing.expect(layout.connection_socket_fds[conn_id] == 123);
    try std.testing.expect(layout.connection_protocols[conn_id] == .http_1_1);
}

test "DOD Network HTTP request processing" {
    var layout = net.DODNetworkLayout.init();
    
    // Add connection first
    const conn_id = try layout.add_connection(456, .http_1_1, 8080, 3001);
    
    // Add HTTP request
    const req_id = try layout.add_request(conn_id, .get);
    
    const stats = layout.get_stats();
    std.debug.print("\nHTTP Request Stats:\n", .{});
    std.debug.print("  Request ID: {d}\n", .{req_id});
    std.debug.print("  Connection ID: {d}\n", .{layout.request_connection_ids[req_id]});
    std.debug.print("  Method: {s}\n", .{@tagName(layout.request_methods[req_id])});
    std.debug.print("  Total requests: {d}\n", .{stats.requests});
    
    try std.testing.expect(req_id == 0);
    try std.testing.expect(layout.request_connection_ids[req_id] == conn_id);
    try std.testing.expect(layout.request_methods[req_id] == .get);
    try std.testing.expect(stats.requests == 1);
}

test "DOD Network SIMD processor" {
    var processor = net.SIMDNetworkProcessor.init();
    var layout = net.DODNetworkLayout.init();
    
    // Add some test connections
    _ = try layout.add_connection(100, .http_1_1, 8080, 4000);
    _ = try layout.add_connection(101, .http_1_1, 8080, 4001);
    _ = try layout.add_connection(102, .tcp, 8080, 4002);
    
    // Process connections in batch
    processor.process_connection_batch(&layout, 0, 3);
    
    const stats = processor.get_stats();
    std.debug.print("\nSIMD Processor Stats:\n", .{});
    std.debug.print("  Connections processed: {d}\n", .{stats.connections});
    std.debug.print("  Batches completed: {d}\n", .{stats.batches});
    
    try std.testing.expect(stats.connections == 3);
    try std.testing.expect(stats.batches == 1);
}

test "DOD Network HTTP parser" {
    var layout = net.DODNetworkLayout.init();
    var parser = net.DODHttpParser.init(&layout);
    
    // Add connection
    const conn_id = try layout.add_connection(789, .http_1_1, 8080, 5000);
    
    // Parse simple HTTP request
    const request_data = "GET /api/test HTTP/1.1\r\nHost: localhost\r\n\r\n";
    const req_id = try parser.parse_request(conn_id, request_data);
    
    const stats = layout.get_stats();
    std.debug.print("\nHTTP Parser Stats:\n", .{});
    std.debug.print("  Parsed request ID: {d}\n", .{req_id});
    std.debug.print("  Method: {s}\n", .{@tagName(layout.request_methods[req_id])});
    std.debug.print("  URL length: {d}\n", .{layout.request_url_lengths[req_id]});
    std.debug.print("  Total requests: {d}\n", .{stats.requests});
    
    try std.testing.expect(layout.request_methods[req_id] == .get);
    try std.testing.expect(layout.request_url_lengths[req_id] > 0);
    try std.testing.expect(stats.requests == 1);
}

test "DOD Network mixed batch processing" {
    var layout = net.DODNetworkLayout.init();
    
    // Add multiple connections and requests
    _ = try layout.add_connection(200, .http_1_1, 8080, 6000);
    _ = try layout.add_connection(201, .http_1_1, 8080, 6001);
    _ = try layout.add_request(0, .get);
    _ = try layout.add_request(1, .post);
    
    // Process mixed batches
    net.process_mixed_batches(2, 2, 0);
    
    const stats = layout.get_stats();
    std.debug.print("\nMixed Batch Processing Stats:\n", .{});
    std.debug.print("  Connections: {d}\n", .{stats.connections});
    std.debug.print("  Requests: {d}\n", .{stats.requests});
    std.debug.print("  Active connections: {d}\n", .{stats.active_connections});
    
    try std.testing.expect(stats.connections == 2);
    try std.testing.expect(stats.requests == 2);
    try std.testing.expect(stats.active_connections == 2);
}
