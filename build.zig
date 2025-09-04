const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Main library module
    const lib = b.addModule("nen-net", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Main executable for testing/demo
    const exe = b.addExecutable(.{
        .name = "nen-net",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.root_module.addImport("nen-net", lib);

    b.installArtifact(exe);

    // Unit tests
    const unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/unit/basic_tests.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    unit_tests.root_module.addImport("nen-net", lib);

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // HTTP tests
    const http_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/unit/http_tests.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    http_tests.root_module.addImport("nen-net", lib);

    const run_http_tests = b.addRunArtifact(http_tests);
    test_step.dependOn(&run_http_tests.step);

    // TCP tests
    const tcp_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/unit/tcp_tests.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    tcp_tests.root_module.addImport("nen-net", lib);

    const run_tcp_tests = b.addRunArtifact(tcp_tests);
    test_step.dependOn(&run_tcp_tests.step);

    // WebSocket tests
    const websocket_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/unit/websocket_tests.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    websocket_tests.root_module.addImport("nen-net", lib);

    const run_websocket_tests = b.addRunArtifact(websocket_tests);
    test_step.dependOn(&run_websocket_tests.step);

    // Connection tests
    const connection_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/unit/connection_tests.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    connection_tests.root_module.addImport("nen-net", lib);

    const run_connection_tests = b.addRunArtifact(connection_tests);
    test_step.dependOn(&run_connection_tests.step);

    // Routing tests
    const routing_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/unit/routing_tests.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    routing_tests.root_module.addImport("nen-net", lib);

    const run_routing_tests = b.addRunArtifact(routing_tests);
    test_step.dependOn(&run_routing_tests.step);

    // Performance tests
    const performance_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/unit/performance_tests.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    performance_tests.root_module.addImport("nen-net", lib);

    const run_performance_tests = b.addRunArtifact(performance_tests);
    test_step.dependOn(&run_performance_tests.step);

    // Standard library comparison benchmark
    const benchmark = b.addExecutable(.{
        .name = "standard_library_comparison",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/standard_library_comparison.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    benchmark.root_module.addImport("nen-net", lib);

    const run_benchmark = b.addRunArtifact(benchmark);
    const benchmark_step = b.step("benchmark", "Run standard library comparison benchmark");
    benchmark_step.dependOn(&run_benchmark.step);

    // Integration tests (placeholder - will be implemented later)
    const integration_step = b.step("test-integration", "Run integration tests");
    // For now, just run the unit tests as integration tests are not yet implemented
    integration_step.dependOn(test_step);

    // Performance tests (placeholder - will be implemented later)
    const perf_step = b.step("test-perf", "Run performance tests");
    // For now, just run the unit tests as performance tests are not yet implemented
    perf_step.dependOn(test_step);

    // Memory tests (placeholder - will be implemented later)
    const memory_step = b.step("test-memory", "Run memory tests");
    // For now, just run the unit tests as memory tests are not yet implemented
    memory_step.dependOn(test_step);

    // Stress tests (placeholder - will be implemented later)
    const stress_step = b.step("test-stress", "Run stress tests");
    // For now, just run the unit tests as stress tests are not yet implemented
    stress_step.dependOn(test_step);

    // Examples
    const examples = b.addExecutable(.{
        .name = "http_server_example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/http_server_example.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    examples.root_module.addImport("nen-net", lib);

    const run_examples = b.addRunArtifact(examples);
    const examples_step = b.step("examples", "Run HTTP server example");
    examples_step.dependOn(&run_examples.step);

    // All tests
    const all_tests = b.step("test-all", "Run all tests");
    all_tests.dependOn(test_step);
    all_tests.dependOn(integration_step);
    all_tests.dependOn(perf_step);
    all_tests.dependOn(memory_step);
    all_tests.dependOn(stress_step);
}
