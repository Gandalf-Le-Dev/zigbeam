const std = @import("std");
const Allocator = std.mem.Allocator;

pub const LogLevel = enum {
    Debug,
    Info,
    Warn,
    Error,
};

pub const LogEntry = struct {
    timestamp: i64,
    level: LogLevel,
    message: []const u8,
    fields: std.StringHashMap([]const u8),
    allocator: Allocator,

    pub fn init(allocator: Allocator) LogEntry {
        return LogEntry{
            .timestamp = std.time.milliTimestamp(),
            .level = .Info,
            .message = "",
            .fields = std.StringHashMap([]const u8).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *LogEntry) void {
        var it = self.fields.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            self.allocator.free(entry.value_ptr.*);
        }
        self.fields.deinit();
    }
};