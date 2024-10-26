const std = @import("std");
const Aurora = @import("aurora");

pub const Logger = struct {
    aurora: *Aurora,
    allocator: std.mem.Allocator,
    show_timestamp: bool,
    include_source_location: bool,
    timestamp_format: TimestampFormat,

    pub const TimestampFormat = enum {
        // Default format: DD-MM-YYYY HH:MM:SS
        default,
        // ISO 8601: YYYY-MM-DD HH:MM:SS
        iso8601,
        // Unix timestamp
        unix,
        // RFC 3339: YYYY-MM-DDThh:mm:ssZ
        rfc3339,
        // Compact format: HH:MM:SS.mmm
        compact,
    };

    pub const Config = struct {
        allocator: std.mem.Allocator = std.heap.page_allocator,
        show_timestamp: bool = true,
        include_source_location: bool = true,
        detect_no_color: bool = false,
        timestamp_format: TimestampFormat = .default,
    };

    pub fn init(config: Config) !Logger {
        const aurora = try config.allocator.create(Aurora);
        aurora.* = Aurora.init(.{
            .allocator = config.allocator,
            .detect_no_color = config.detect_no_color,
        });
        return Logger{
            .aurora = aurora,
            .allocator = config.allocator,
            .show_timestamp = config.show_timestamp,
            .include_source_location = config.include_source_location,
            .timestamp_format = config.timestamp_format,
        };
    }

    pub fn deinit(self: *Logger) void {
        self.aurora.deinit();
    }

    fn formatTimestamp(self: *Logger) []const u8 {
        const now = std.time.timestamp();
        const ts = std.time.epoch.EpochSeconds{ .secs = @as(u64, @intCast(now)) };
        const dt = ts.getEpochDay();
        const ds = ts.getDaySeconds();
        const yd = dt.calculateYearDay();
        const month_day = yd.calculateMonthDay();

        return switch (self.timestamp_format) {
            .default => self.aurora.gray().fmt("{d:0>2}-{d:0>2}-{d:0>4} {d:0>2}:{d:0>2}:{d:0>2} ", .{
                month_day.day_index + 1,
                month_day.month.numeric(),
                yd.year,
                ds.getHoursIntoDay(),
                ds.getMinutesIntoHour(),
                ds.getSecondsIntoMinute(),
            }),
            .iso8601 => self.aurora.gray().fmt("{d:0>4}-{d:0>2}-{d:0>2} {d:0>2}:{d:0>2}:{d:0>2} ", .{
                yd.year,
                month_day.month.numeric(),
                month_day.day_index + 1,
                ds.getHoursIntoDay(),
                ds.getMinutesIntoHour(),
                ds.getSecondsIntoMinute(),
            }),
            .unix => self.aurora.gray().fmt("{d} ", .{now}),
            .rfc3339 => self.aurora.gray().fmt("{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}Z ", .{
                yd.year,
                month_day.month.numeric(),
                month_day.day_index + 1,
                ds.getHoursIntoDay(),
                ds.getMinutesIntoHour(),
                ds.getSecondsIntoMinute(),
            }),
            .compact => {
                const nanos = @as(u32, @intCast(@mod(std.time.nanoTimestamp(), std.time.ns_per_s)));
                const millis = @divFloor(nanos, std.time.ns_per_ms);

                return self.aurora.gray().fmt("{d:0>2}:{d:0>2}:{d:0>2}.{d:0>3} ", .{
                    ds.getHoursIntoDay(),
                    ds.getMinutesIntoHour(),
                    ds.getSecondsIntoMinute(),
                    millis,
                });
            },
        };
    }

    fn formatPrefix(
        self: *Logger,
        comptime level: std.log.Level,
    ) []const u8 {
        var result: []const u8 = "";

        result = switch (level) {
            .debug => self.aurora.cyan().fmt("[DEBUG] ", .{}),
            .info => self.aurora.green().fmt("[INFO] ", .{}),
            .warn => self.aurora.yellow().fmt("[WARN] ", .{}),
            .err => self.aurora.red().fmt("[ERROR] ", .{}),
        };

        return result;
    }

    fn formatLocation(
        self: *Logger,
        file: []const u8,
        line: usize,
    ) []const u8 {
        return self.aurora.gray().fmt(" ({s}:{d})", .{ file, line });
    }

    pub fn log(
        self: *Logger,
        comptime level: std.log.Level,
        comptime format: []const u8,
        args: anytype,
        source_location: std.builtin.SourceLocation,
    ) void {
        // Skip if below minimum level
        if (@intFromEnum(level) > @intFromEnum(std.options.log_level)) {
            return;
        }

        const writer = std.io.getStdErr().writer();

        // Get the prefix
        const prefix = self.formatPrefix(level);

        // Write timestamp if configured
        if (self.show_timestamp) {
            const ts_str = self.formatTimestamp();
            writer.writeAll(ts_str) catch unreachable;
        }

        // Write the level prefix
        writer.writeAll(prefix) catch unreachable;

        // Write the formatted message
        writer.print(format, args) catch unreachable;

        // Write the source location if configured
        if (self.include_source_location) {
            const loc_str = self.formatLocation(source_location.file, source_location.line);
            writer.writeAll(loc_str) catch unreachable;
        }

        writer.writeByte('\n') catch unreachable;
    }

    pub fn debug(
        self: *Logger,
        comptime format: []const u8,
        args: anytype,
        source_location: std.builtin.SourceLocation,
    ) void {
        self.log(.debug, format, args, source_location);
    }

    pub fn info(
        self: *Logger,
        comptime format: []const u8,
        args: anytype,
        source_location: std.builtin.SourceLocation,
    ) void {
        self.log(.info, format, args, source_location);
    }

    pub fn warn(
        self: *Logger,
        comptime format: []const u8,
        args: anytype,
        source_location: std.builtin.SourceLocation,
    ) void {
        self.log(.warn, format, args, source_location);
    }

    pub fn err(
        self: *Logger,
        comptime format: []const u8,
        args: anytype,
        source_location: std.builtin.SourceLocation,
    ) void {
        self.log(.err, format, args, source_location);
    }
};
