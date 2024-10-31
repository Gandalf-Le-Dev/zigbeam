const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const aurora_dep = b.dependency("aurora", .{});
    const aurora_mod = aurora_dep.module("aurora");

    // Create the module
    const zigbeam_mod = b.addModule("zigbeam", .{
        .root_source_file = b.path("src/zigbeam.zig"),
        .imports = &.{
            .{ .name = "aurora", .module = aurora_mod },
        },
    });

    // Create executable for integration tests
    const exe = b.addExecutable(.{
        .name = "zigbeam-test",  // Changed name to clarify it's for testing
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("zigbeam", zigbeam_mod);
    
    // Add run step for integration tests
    const run = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run integration tests");  // Updated description
    run_step.dependOn(&run.step);

    // Unit tests
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/zigbeam.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_tests.root_module.addImport("aurora", aurora_mod);

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}