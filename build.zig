const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const logger_module = b.addModule("logger", .{
        .root_source_file = b.path("src/logger.zig")
    });

    const lib = b.addStaticLibrary(.{
        .name = "logger",
        .root_source_file = b.path("src/logger.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/logger.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);

    // Example
    const example = b.addExecutable(.{
        .name = "logger-example",
        .root_source_file = b.path("example/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    example.root_module.addImport(logger_module);

    const run_example = b.addRunArtifact(example);
    const run_example_step = b.step("run-example", "Run the example");
    run_example_step.dependOn(&run_example.step);

    b.installArtifact(example);
}