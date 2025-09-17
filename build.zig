const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // External dependencies - point to parent directory
    const nen_core = b.addModule("nen-core", .{
        .root_source_file = b.path("../nen-core/src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const nen_io = b.addModule("nen-io", .{
        .root_source_file = b.path("../nen-io/src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const nen_json = b.addModule("nen-json", .{
        .root_source_file = b.path("../nen-json/src/lib.zig"),
        .target = target,
        .optimize = optimize,
    }); // Main library module
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
    exe.root_module.addImport("nen-core", nen_core);
    exe.root_module.addImport("nen-io", nen_io);
    exe.root_module.addImport("nen-json", nen_json);

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
    unit_tests.root_module.addImport("nen-core", nen_core);
    unit_tests.root_module.addImport("nen-io", nen_io);
    unit_tests.root_module.addImport("nen-json", nen_json);

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
    http_tests.root_module.addImport("nen-core", nen_core);
    http_tests.root_module.addImport("nen-io", nen_io);
    http_tests.root_module.addImport("nen-json", nen_json);

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
    tcp_tests.root_module.addImport("nen-core", nen_core);
    tcp_tests.root_module.addImport("nen-io", nen_io);
    tcp_tests.root_module.addImport("nen-json", nen_json);

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
    websocket_tests.root_module.addImport("nen-core", nen_core);
    websocket_tests.root_module.addImport("nen-io", nen_io);
    websocket_tests.root_module.addImport("nen-json", nen_json);

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
    connection_tests.root_module.addImport("nen-core", nen_core);
    connection_tests.root_module.addImport("nen-io", nen_io);
    connection_tests.root_module.addImport("nen-json", nen_json);

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
    routing_tests.root_module.addImport("nen-core", nen_core);
    routing_tests.root_module.addImport("nen-io", nen_io);
    routing_tests.root_module.addImport("nen-json", nen_json);

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
    performance_tests.root_module.addImport("nen-core", nen_core);
    performance_tests.root_module.addImport("nen-io", nen_io);
    performance_tests.root_module.addImport("nen-json", nen_json);

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
    benchmark.root_module.addImport("nen-core", nen_core);
    benchmark.root_module.addImport("nen-io", nen_io);
    benchmark.root_module.addImport("nen-json", nen_json);

    const run_benchmark = b.addRunArtifact(benchmark);
    const benchmark_step = b.step("benchmark", "Run standard library comparison benchmark");
    benchmark_step.dependOn(&run_benchmark.step);

    // Real-world performance benchmark
    const real_benchmark = b.addExecutable(.{
        .name = "real_world_benchmark",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/real_world_benchmark.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    real_benchmark.root_module.addImport("nen-net", lib);
    real_benchmark.root_module.addImport("nen-core", nen_core);
    real_benchmark.root_module.addImport("nen-io", nen_io);
    real_benchmark.root_module.addImport("nen-json", nen_json);

    const run_real_benchmark = b.addRunArtifact(real_benchmark);
    const real_benchmark_step = b.step("benchmark-real", "Run real-world performance benchmark");
    real_benchmark_step.dependOn(&run_real_benchmark.step);

    // Simple performance test
    const simple_benchmark = b.addExecutable(.{
        .name = "simple_performance_test",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/simple_performance_test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    simple_benchmark.root_module.addImport("nen-net", lib);
    simple_benchmark.root_module.addImport("nen-core", nen_core);
    simple_benchmark.root_module.addImport("nen-io", nen_io);
    simple_benchmark.root_module.addImport("nen-json", nen_json);

    const run_simple_benchmark = b.addRunArtifact(simple_benchmark);
    const simple_benchmark_step = b.step("benchmark-simple", "Run simple performance test");
    simple_benchmark_step.dependOn(&run_simple_benchmark.step);

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
    examples.root_module.addImport("nen-core", nen_core);
    examples.root_module.addImport("nen-io", nen_io);
    examples.root_module.addImport("nen-json", nen_json);

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
