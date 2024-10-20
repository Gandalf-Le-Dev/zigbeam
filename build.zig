const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("zigbeam", .{
        .root_source_file = b.path("src/zigbeam.zig"),
        .target = target,
        .optimize = optimize,
    });

    const zigbeam_lib = b.addStaticLibrary(.{
        .name = "zigbeam",
        .root_source_file = b.path("src/zigbeam.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(zigbeam_lib);

    // Add test step
    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/zigbeam.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(main_tests);
    main_tests.linkLibrary(zigbeam_lib);
    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
