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

    // Create the library
    const zigbeam_lib = b.addStaticLibrary(.{
        .name = "zigbeam",
        .root_source_file = b.path("src/zigbeam.zig"),
        .target = target,
        .optimize = optimize,
    });
    zigbeam_lib.root_module.addImport("aurora", aurora_mod);
    b.installArtifact(zigbeam_lib);

    // Create executable
    const exe = b.addExecutable(.{
        .name = "zigbeam",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("aurora", aurora_mod);
    exe.root_module.addImport("zigbeam", zigbeam_mod);
    b.installArtifact(exe);

    // Add run step
    const run = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run library");
    run_step.dependOn(&run.step);

    // Add test step
    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/zigbeam.zig"),
        .target = target,
        .optimize = optimize,
    });
    main_tests.root_module.addImport("aurora", aurora_mod);

    const run_main_tests = b.addRunArtifact(main_tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
