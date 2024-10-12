const std = @import("std");
const builtin = @import("builtin");

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