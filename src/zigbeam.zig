const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;

// ANSI color codes
const Color = enum(u8) {
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    
    fn asAnsi(self: Color) []const u8 {
        return switch (self) {
            .red => "\x1b[31m",
            .green => "\x1b[32m",
            .yellow => "\x1b[33m",
            .blue => "\x1b[34m",
        };
    }
};

// Mapping log levels to colors
fn levelColor(level: std.log.Level) Color {
    return switch (level) {
        .err => .red,
        .warn => .yellow,
        .info => .green,
        .debug => .blue,
    };
}

// Compile-time function to generate colored level text
fn coloredLevel(comptime level: std.log.Level) []const u8 {
    const color = comptime levelColor(level).asAnsi();
    return color ++ @tagName(level) ++ "\x1b[0m";
}

pub fn log(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const level = std.options.log_level;
    const prefix = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";

    if (@intFromEnum(message_level) <= @intFromEnum(level)) {
        const stderr = std.io.getStdErr().writer();
        
        std.debug.lockStdErr();
        defer std.debug.unlockStdErr();
        
        nosuspend stderr.print("[" ++ coloredLevel(message_level) ++ "]" ++ prefix ++ format ++ "\n", args) catch return;
    }
}


pub const log_level: std.log.Level = .info;

// Test helper function to capture log output
fn testLog(comptime message_level: std.log.Level, comptime scope: @Type(.EnumLiteral), comptime format: []const u8, args: anytype) ![]const u8 {
    var buf = std.ArrayList(u8).init(testing.allocator);
    defer buf.deinit();

    const prefix = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";
    try buf.writer().print("[" ++ coloredLevel(message_level) ++ "]" ++ prefix ++ format ++ "\n", args);

    return buf.toOwnedSlice();
}

test "log levels and colors" {
    {
        const result = try testLog(.err, .default, "Error message", .{});
        defer testing.allocator.free(result);
        try testing.expect(std.mem.startsWith(u8, result, "[\x1b[31merr\x1b[0m]"));
        try testing.expect(std.mem.endsWith(u8, result, "Error message\n"));
    }
    {
        const result = try testLog(.warn, .default, "Warning message", .{});
        defer testing.allocator.free(result);
        try testing.expect(std.mem.startsWith(u8, result, "[\x1b[33mwarn\x1b[0m]"));
        try testing.expect(std.mem.endsWith(u8, result, "Warning message\n"));
    }
    {
        const result = try testLog(.info, .default, "Info message", .{});
        defer testing.allocator.free(result);
        try testing.expect(std.mem.startsWith(u8, result, "[\x1b[32minfo\x1b[0m]"));
        try testing.expect(std.mem.endsWith(u8, result, "Info message\n"));
    }
    {
        const result = try testLog(.debug, .default, "Debug message", .{});
        defer testing.allocator.free(result);
        try testing.expect(std.mem.startsWith(u8, result, "[\x1b[34mdebug\x1b[0m]"));
        try testing.expect(std.mem.endsWith(u8, result, "Debug message\n"));
    }
}

test "log scopes" {
    const result = try testLog(.info, .test_scope, "Scoped message", .{});
    defer testing.allocator.free(result);
    try testing.expect(std.mem.startsWith(u8, result, "[\x1b[32minfo\x1b[0m](test_scope): "));
    try testing.expect(std.mem.endsWith(u8, result, "Scoped message\n"));
}

test "log formatting" {
    const result = try testLog(.info, .default, "Formatted {s}: {d}", .{ "number", 42 });
    defer testing.allocator.free(result);
    try testing.expect(std.mem.endsWith(u8, result, "Formatted number: 42\n"));
}