const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("zigbeam", .{
        .root_source_file = b.path("src/zigbeam.zig"),
        .target = target,
        .optimize = optimize,
    });
}