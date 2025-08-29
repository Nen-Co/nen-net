const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Main library module
    const lib = b.addStaticLibrary(.{
        .name = "nen-net",
        .root_source_file = .{ .cwd_relative = "src/lib.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Install library
    b.installArtifact(lib);

    // Main executable for testing/demo
    const exe = b.addExecutable(.{
        .name = "nen-net",
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibrary(lib);

    b.installArtifact(exe);

    // Unit tests
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "tests/unit/basic_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    unit_tests.linkLibrary(lib);

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // HTTP tests
    const http_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "tests/unit/http_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    http_tests.linkLibrary(lib);

    const run_http_tests = b.addRunArtifact(http_tests);
    test_step.dependOn(&run_http_tests.step);

    // TCP tests
    const tcp_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "tests/unit/tcp_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    tcp_tests.linkLibrary(lib);

    const run_tcp_tests = b.addRunArtifact(tcp_tests);
    test_step.dependOn(&run_tcp_tests.step);

    // WebSocket tests
    const websocket_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "tests/unit/websocket_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    websocket_tests.linkLibrary(lib);

    const run_websocket_tests = b.addRunArtifact(websocket_tests);
    test_step.dependOn(&run_websocket_tests.step);

    // Connection tests
    const connection_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "tests/unit/connection_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    connection_tests.linkLibrary(lib);

    const run_connection_tests = b.addRunArtifact(connection_tests);
    test_step.dependOn(&run_connection_tests.step);

    // Routing tests
    const routing_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "tests/unit/routing_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    routing_tests.linkLibrary(lib);

    const run_routing_tests = b.addRunArtifact(routing_tests);
    test_step.dependOn(&run_routing_tests.step);

    // Performance tests
    const performance_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "tests/unit/performance_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    performance_tests.linkLibrary(lib);

    const run_performance_tests = b.addRunArtifact(performance_tests);
    test_step.dependOn(&run_performance_tests.step);

    // Integration tests
    const integration_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "tests/integration/server_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    integration_tests.linkLibrary(lib);

    const run_integration_tests = b.addRunArtifact(integration_tests);
    const integration_step = b.step("test-integration", "Run integration tests");
    integration_step.dependOn(&run_integration_tests.step);

    // Performance tests
    const perf_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "tests/performance/perf_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    perf_tests.linkLibrary(lib);

    const run_perf_tests = b.addRunArtifact(perf_tests);
    const perf_step = b.step("test-perf", "Run performance tests");
    perf_step.dependOn(&run_perf_tests.step);

    // Memory tests
    const memory_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "tests/memory/memory_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    memory_tests.linkLibrary(lib);

    const run_memory_tests = b.addRunArtifact(memory_tests);
    const memory_step = b.step("test-memory", "Run memory tests");
    memory_step.dependOn(&run_memory_tests.step);

    // Stress tests
    const stress_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "tests/stress/stress_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    stress_tests.linkLibrary(lib);

    const run_stress_tests = b.addRunArtifact(stress_tests);
    const stress_step = b.step("test-stress", "Run stress tests");
    stress_step.dependOn(&run_stress_tests.step);

    // Examples
    const examples = b.addExecutable(.{
        .name = "examples",
        .root_source_file = .{ .cwd_relative = "examples/http_server_demo.zig" },
        .target = target,
        .optimize = optimize,
    });
    examples.linkLibrary(lib);

    const run_examples = b.addRunArtifact(examples);
    const examples_step = b.step("examples", "Run examples");
    examples_step.dependOn(&run_examples.step);

    // Benchmarks
    const benchmarks = b.addExecutable(.{
        .name = "benchmarks",
        .root_source_file = .{ .cwd_relative = "benchmarks/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    benchmarks.linkLibrary(lib);

    const run_benchmarks = b.addRunArtifact(benchmarks);
    const benchmark_step = b.step("benchmark", "Run benchmarks");
    benchmark_step.dependOn(&run_benchmarks.step);

    // All tests
    const all_tests = b.step("test-all", "Run all tests");
    all_tests.dependOn(test_step);
    all_tests.dependOn(integration_step);
    all_tests.dependOn(perf_step);
    all_tests.dependOn(memory_step);
    all_tests.dependOn(stress_step);
}
