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
    lib.addImport("nen-core", nen_core);
    lib.addImport("nen-io", nen_io);
    lib.addImport("nen-json", nen_json);

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

    // Fair comparison benchmark
    const fair_benchmark = b.addExecutable(.{
        .name = "fair_comparison",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/fair_comparison.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    fair_benchmark.root_module.addImport("nen-net", lib);
    fair_benchmark.root_module.addImport("nen-core", nen_core);
    fair_benchmark.root_module.addImport("nen-io", nen_io);
    fair_benchmark.root_module.addImport("nen-json", nen_json);

    const run_fair_benchmark = b.addRunArtifact(fair_benchmark);
    const fair_benchmark_step = b.step("benchmark-fair", "Run fair performance comparison");
    fair_benchmark_step.dependOn(&run_fair_benchmark.step);

    // http.zig comparison benchmark
    const http_zig_benchmark = b.addExecutable(.{
        .name = "http_zig_comparison",
        .root_module = b.createModule(.{
            .root_source_file = b.path("third_party_reference/http_zig_comparison.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    http_zig_benchmark.root_module.addImport("nen-net", lib);
    http_zig_benchmark.root_module.addImport("nen-core", nen_core);
    http_zig_benchmark.root_module.addImport("nen-io", nen_io);
    http_zig_benchmark.root_module.addImport("nen-json", nen_json);

    const run_http_zig_benchmark = b.addRunArtifact(http_zig_benchmark);
    const http_zig_benchmark_step = b.step("benchmark-http-zig", "Run nen-net vs http.zig comparison");
    http_zig_benchmark_step.dependOn(&run_http_zig_benchmark.step);

    // Simple http.zig comparison benchmark
    const http_zig_simple_benchmark = b.addExecutable(.{
        .name = "http_zig_simple",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/http_zig_simple.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    http_zig_simple_benchmark.root_module.addImport("nen-net", lib);
    http_zig_simple_benchmark.root_module.addImport("nen-core", nen_core);
    http_zig_simple_benchmark.root_module.addImport("nen-io", nen_io);
    http_zig_simple_benchmark.root_module.addImport("nen-json", nen_json);

    const run_http_zig_simple_benchmark = b.addRunArtifact(http_zig_simple_benchmark);
    const http_zig_simple_benchmark_step = b.step("benchmark-http-zig-simple", "Run simple nen-net vs http.zig comparison");
    http_zig_simple_benchmark_step.dependOn(&run_http_zig_simple_benchmark.step);

    // Real comparison benchmark
    const real_comparison_benchmark = b.addExecutable(.{
        .name = "real_comparison",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/real_comparison.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    real_comparison_benchmark.root_module.addImport("nen-net", lib);
    real_comparison_benchmark.root_module.addImport("nen-core", nen_core);
    real_comparison_benchmark.root_module.addImport("nen-io", nen_io);
    real_comparison_benchmark.root_module.addImport("nen-json", nen_json);

    const run_real_comparison_benchmark = b.addRunArtifact(real_comparison_benchmark);
    const real_comparison_benchmark_step = b.step("benchmark-real-comparison", "Run real nen-net vs std comparison");
    real_comparison_benchmark_step.dependOn(&run_real_comparison_benchmark.step);

    // Fair HTTP comparison benchmark
    const fair_http_benchmark = b.addExecutable(.{
        .name = "fair_http_comparison",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/fair_http_comparison.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    fair_http_benchmark.root_module.addImport("nen-net", lib);
    fair_http_benchmark.root_module.addImport("nen-core", nen_core);
    fair_http_benchmark.root_module.addImport("nen-io", nen_io);
    fair_http_benchmark.root_module.addImport("nen-json", nen_json);

    const run_fair_http_benchmark = b.addRunArtifact(fair_http_benchmark);
    const fair_http_benchmark_step = b.step("benchmark-fair-http", "Run fair nen-net vs std HTTP comparison");
    fair_http_benchmark_step.dependOn(&run_fair_http_benchmark.step);

    // Simple fair comparison benchmark
    const simple_fair_benchmark = b.addExecutable(.{
        .name = "simple_fair_comparison",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/simple_fair_comparison.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    simple_fair_benchmark.root_module.addImport("nen-net", lib);
    simple_fair_benchmark.root_module.addImport("nen-core", nen_core);
    simple_fair_benchmark.root_module.addImport("nen-io", nen_io);
    simple_fair_benchmark.root_module.addImport("nen-json", nen_json);

    const run_simple_fair_benchmark = b.addRunArtifact(simple_fair_benchmark);
    const simple_fair_benchmark_step = b.step("benchmark-simple-fair", "Run simple fair nen-net vs std comparison");
    simple_fair_benchmark_step.dependOn(&run_simple_fair_benchmark.step);

    // Realistic comparison benchmark
    const realistic_benchmark = b.addExecutable(.{
        .name = "realistic_comparison",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/realistic_comparison.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    realistic_benchmark.root_module.addImport("nen-net", lib);
    realistic_benchmark.root_module.addImport("nen-core", nen_core);
    realistic_benchmark.root_module.addImport("nen-io", nen_io);
    realistic_benchmark.root_module.addImport("nen-json", nen_json);

    const run_realistic_benchmark = b.addRunArtifact(realistic_benchmark);
    const realistic_benchmark_step = b.step("benchmark-realistic", "Run realistic nen-net vs std comparison");
    realistic_benchmark_step.dependOn(&run_realistic_benchmark.step);

    // Real http.zig comparison benchmark
    const real_http_zig_benchmark = b.addExecutable(.{
        .name = "real_http_zig_comparison",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/real_http_zig_comparison.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    real_http_zig_benchmark.root_module.addImport("nen-net", lib);
    real_http_zig_benchmark.root_module.addImport("nen-core", nen_core);
    real_http_zig_benchmark.root_module.addImport("nen-io", nen_io);
    real_http_zig_benchmark.root_module.addImport("nen-json", nen_json);
    real_http_zig_benchmark.root_module.addImport("httpz", b.dependency("httpz", .{ .target = target, .optimize = optimize }).module("httpz"));

    const run_real_http_zig_benchmark = b.addRunArtifact(real_http_zig_benchmark);
    const real_http_zig_benchmark_step = b.step("benchmark-real-http-zig", "Run real nen-net vs http.zig comparison");
    real_http_zig_benchmark_step.dependOn(&run_real_http_zig_benchmark.step);

    // Real server executables for end-to-end testing
    const server_nen_net = b.addExecutable(.{
        .name = "server_nen_net",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/server_nen_net.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const server_http_zig = b.addExecutable(.{
        .name = "server_http_zig",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/server_http_zig.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    server_http_zig.root_module.addImport("httpz", b.dependency("httpz", .{ .target = target, .optimize = optimize }).module("httpz"));

    // Real benchmark step
    const real_benchmark_servers_step = b.step("benchmark-real-servers", "Run real end-to-end server benchmark");
    real_benchmark_servers_step.dependOn(&server_nen_net.step);
    real_benchmark_servers_step.dependOn(&server_http_zig.step);

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
