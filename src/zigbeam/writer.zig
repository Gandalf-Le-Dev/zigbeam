const std = @import("std");
const types = @import("types.zig");

pub fn writeEntry(entry: *const types.LogEntry) !void {
    const writer = std.io.getStdOut().writer();
    
    try writer.print("{d} [{s}] {s}", .{ entry.timestamp, @tagName(entry.level), entry.message });

    var it = entry.fields.iterator();
    while (it.next()) |kv| {
        try writer.print(" {s}={s}", .{ kv.key_ptr.*, kv.value_ptr.* });
    }
    try writer.print("\n", .{});
}