// Test-safe DOD implementation for nen-net
// Uses heap allocation to prevent stack overflow during testing

const std = @import("std");
const testing = std.testing;
const test_dod_config = @import("test_dod_config.zig");

test "Test-safe DOD network layout initialization" {
    const allocator = testing.allocator;

    const layout = try test_dod_config.createTestDODLayout(allocator);
    defer allocator.destroy(layout);

    try testing.expect(layout.connection_count == 0);
    try testing.expect(layout.request_count == 0);
    try testing.expect(layout.response_count == 0);
}

test "Test-safe DOD connection management" {
    const allocator = testing.allocator;

    const layout = try test_dod_config.createTestDODLayout(allocator);
    defer allocator.destroy(layout);

    const conn1 = try layout.addConnection(1001);
    const conn2 = try layout.addConnection(1002);

    try testing.expect(conn1 == 0);
    try testing.expect(conn2 == 1);
    try testing.expect(layout.connection_count == 2);
    try testing.expect(layout.connection_ids[0] == 1001);
    try testing.expect(layout.connection_ids[1] == 1002);
    try testing.expect(layout.connection_active[0] == true);
    try testing.expect(layout.connection_active[1] == true);
}

test "Test-safe DOD request management" {
    const allocator = testing.allocator;

    const layout = try test_dod_config.createTestDODLayout(allocator);
    defer allocator.destroy(layout);

    const req1 = try layout.addRequest(2001, 1, 1024); // GET request
    const req2 = try layout.addRequest(2002, 2, 2048); // POST request

    try testing.expect(req1 == 0);
    try testing.expect(req2 == 1);
    try testing.expect(layout.request_count == 2);
    try testing.expect(layout.request_ids[0] == 2001);
    try testing.expect(layout.request_methods[0] == 1);
    try testing.expect(layout.request_sizes[0] == 1024);
}

test "Test-safe DOD response management" {
    const allocator = testing.allocator;

    const layout = try test_dod_config.createTestDODLayout(allocator);
    defer allocator.destroy(layout);

    const resp1 = try layout.addResponse(3001, 200, 512);
    const resp2 = try layout.addResponse(3002, 404, 128);

    try testing.expect(resp1 == 0);
    try testing.expect(resp2 == 1);
    try testing.expect(layout.response_count == 2);
    try testing.expect(layout.response_status_codes[0] == 200);
    try testing.expect(layout.response_status_codes[1] == 404);
}

test "Test-safe DOD SIMD connection processing" {
    const allocator = testing.allocator;

    const layout = try test_dod_config.createTestDODLayout(allocator);
    defer allocator.destroy(layout);

    // Add some connections
    _ = try layout.addConnection(1001);
    _ = try layout.addConnection(1002);
    _ = try layout.addConnection(1003);

    var connection_indices = [_]u32{ 0, 1, 2 };
    const processed = test_dod_config.TestSIMDOperations.processConnectionsBatch(layout, &connection_indices);

    try testing.expect(processed == 3);
}

test "Test-safe DOD SIMD request validation" {
    const allocator = testing.allocator;

    const layout = try test_dod_config.createTestDODLayout(allocator);
    defer allocator.destroy(layout);

    // Add some requests
    _ = try layout.addRequest(2001, 1, 1024); // Valid request
    _ = try layout.addRequest(2002, 2, 2048); // Valid request
    _ = try layout.addRequest(2003, 0, 0); // Invalid request

    var validation_results: [3]bool = undefined;
    const validated = test_dod_config.TestSIMDOperations.validateRequestsBatch(layout, &validation_results);

    try testing.expect(validated == 3);
    try testing.expect(validation_results[0] == true); // Valid
    try testing.expect(validation_results[1] == true); // Valid
    try testing.expect(validation_results[2] == false); // Invalid (method=0, size=0)
}

test "Test-safe DOD connection limit handling" {
    const allocator = testing.allocator;

    const layout = try test_dod_config.createTestDODLayout(allocator);
    defer allocator.destroy(layout);

    // Add connections up to the limit
    for (0..test_dod_config.TEST_DOD_CONSTANTS.MAX_CONNECTIONS) |i| {
        _ = try layout.addConnection(@intCast(i + 1000));
    }

    // Try to add one more - should fail
    const result = layout.addConnection(9999);
    try testing.expectError(error.ConnectionLimitExceeded, result);

    try testing.expect(layout.connection_count == test_dod_config.TEST_DOD_CONSTANTS.MAX_CONNECTIONS);
}

test "Test-safe DOD active connection retrieval" {
    const allocator = testing.allocator;

    const layout = try test_dod_config.createTestDODLayout(allocator);
    defer allocator.destroy(layout);

    // Add some connections
    _ = try layout.addConnection(1001);
    _ = try layout.addConnection(1002);
    _ = try layout.addConnection(1003);

    // Deactivate middle connection
    layout.connection_active[1] = false;

    var active_connections: [8]u32 = undefined;
    const active_count = layout.getActiveConnections(&active_connections);

    try testing.expect(active_count == 2);
    try testing.expect(active_connections[0] == 0); // First connection
    try testing.expect(active_connections[1] == 2); // Third connection (second was deactivated)
}

test "Test-safe DOD memory usage" {
    const allocator = testing.allocator;

    // Test that we can create multiple layouts without stack overflow
    var layouts: [4]*test_dod_config.TestDODNetworkLayout = undefined;

    for (0..4) |i| {
        layouts[i] = try test_dod_config.createTestDODLayout(allocator);
        _ = try layouts[i].addConnection(@intCast(i + 1000));
    }

    // Verify all layouts are independent
    for (0..4) |i| {
        try testing.expect(layouts[i].connection_count == 1);
        try testing.expect(layouts[i].connection_ids[0] == i + 1000);
    }

    // Clean up
    for (0..4) |i| {
        allocator.destroy(layouts[i]);
    }
}

test "Test-safe DOD batch processing limits" {
    const allocator = testing.allocator;

    const layout = try test_dod_config.createTestDODLayout(allocator);
    defer allocator.destroy(layout);

    // Test that batch processing respects limits
    const batch_size = test_dod_config.TEST_DOD_CONSTANTS.SIMD_CONNECTION_BATCH;
    try testing.expect(batch_size == 4); // Verify reduced batch size

    // Add connections beyond batch size
    for (0..6) |i| {
        _ = try layout.addConnection(@intCast(i + 1000));
    }

    var connection_indices = [_]u32{ 0, 1, 2, 3, 4, 5 };
    const processed = test_dod_config.TestSIMDOperations.processConnectionsBatch(layout, &connection_indices);

    try testing.expect(processed == 6); // All should be processed in batches of 4, then 2
}

// Performance test to ensure test overhead is minimal
test "Test-safe DOD performance baseline" {
    const allocator = testing.allocator;

    var timer = try std.time.Timer.start();

    const layout = try test_dod_config.createTestDODLayout(allocator);
    defer allocator.destroy(layout);

    // Add maximum connections
    for (0..test_dod_config.TEST_DOD_CONSTANTS.MAX_CONNECTIONS) |i| {
        _ = try layout.addConnection(@intCast(i + 1000));
    }

    // Process all connections
    var connection_indices: [test_dod_config.TEST_DOD_CONSTANTS.MAX_CONNECTIONS]u32 = undefined;
    for (0..test_dod_config.TEST_DOD_CONSTANTS.MAX_CONNECTIONS) |i| {
        connection_indices[i] = @intCast(i);
    }

    const processed = test_dod_config.TestSIMDOperations.processConnectionsBatch(layout, &connection_indices);

    const elapsed = timer.read();

    try testing.expect(processed == test_dod_config.TEST_DOD_CONSTANTS.MAX_CONNECTIONS);
    try testing.expect(elapsed < std.time.ns_per_ms); // Should complete in under 1ms
}
