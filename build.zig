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
