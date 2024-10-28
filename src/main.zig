const std = @import("std");
const Logger = @import("zigbeam").Logger;

pub fn main() void {
    const log = Logger.init(.{
        .allocator = std.heap.page_allocator,
        .detect_no_color = false,
        .include_source_location = true,
        .show_timestamp = true,
        .timestamp_format = .default,
    }) catch unreachable;
    defer log.deinit();

    // Use the logger
    log.debug("Debug message: {s}", .{"test"}, @src());
    log.info("Info message with value: {d}", .{42}, @src());
    log.warn("Warning message", .{}, @src());
    log.err("Error occurred: {s}", .{"something went wrong"}, @src());

    // Changed from var to const
    const scoped = log.scoped("custom_scope");
    scoped.info("Scoped message: {s}", .{"hello"}, @src());
}