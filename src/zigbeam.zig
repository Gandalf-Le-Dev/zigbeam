const std = @import("std");
const Aurora = @import("aurora");

inline fn createStyledString(preset: Aurora, comptime text: []const u8) []const u8 {
    return preset.open ++ text ++ preset.close;
}

const Presets = struct {
    const debug_prefix = blk: {
        var a = Aurora{};
        const preset = a.dim().magenta().bold().createPreset();
        break :blk createStyledString(preset, "[DEBUG]");
    };

    const info_prefix = blk: {
        var a = Aurora{};
        const preset = a.green().bold().createPreset();
        break :blk createStyledString(preset, "[INFO]");
    };

    const warn_prefix = blk: {
        var a = Aurora{};
        const preset = a.yellow().bold().createPreset();
        break :blk createStyledString(preset, "[WARN]");
    };

    const err_prefix = blk: {
        var a = Aurora{};
        const preset = a.red().bold().createPreset();
        break :blk createStyledString(preset, "[ERROR]");
    };

    const prefix_text = blk: {
        var a = Aurora{};
        break :blk a.dim().createPreset();
    };

    const debug_text = blk: {
        var a = Aurora{};
        break :blk a.dim().createPreset();
    };

    const warn_text = blk: {
        var a = Aurora{};
        break :blk a.yellow().createPreset();
    };

    const err_text = blk: {
        var a = Aurora{};
        break :blk a.red().createPreset();
    };

    const timestamp = blk: {
        var a = Aurora{};
        const preset = a.gray().createPreset();
        break :blk createStyledString(preset, "{d} ");
    };

    const default_prefix = " ";
};

inline fn getScopePrefix(comptime scope: @Type(.EnumLiteral)) []const u8 {
    if (scope == .default) return Presets.default_prefix;
    
    const scope_str = "(" ++ @tagName(scope) ++ ") ";
    return createStyledString(Presets.prefix_text, scope_str);
}

inline fn getColoredMessage(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
) []const u8 {
    const prefix = comptime getScopePrefix(scope);
    
    const level_prefix = switch (message_level) {
        .debug => Presets.debug_prefix,
        .info => Presets.info_prefix,
        .warn => Presets.warn_prefix,
        .err => Presets.err_prefix,
    };

    const message = switch (message_level) {
        .debug => createStyledString(Presets.debug_text, format),
        .info => format,
        .warn => createStyledString(Presets.warn_text, format),
        .err => createStyledString(Presets.err_text, format),
    };

    return comptime level_prefix ++ prefix ++ message;
}

pub fn defaultLog(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const colored = comptime getColoredMessage(message_level, scope, format);
    const now = std.time.timestamp();

    const stderr = std.io.getStdErr().writer();
    var bw = std.io.bufferedWriter(stderr);
    const writer = bw.writer();
    std.debug.lockStdErr();
    defer std.debug.unlockStdErr();
    nosuspend {
        writer.print(Presets.timestamp ++ colored ++ "\n", .{now} ++ args) catch return;
        bw.flush() catch return;
    }
}