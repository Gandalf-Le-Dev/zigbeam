const std = @import("std");
const Allocator = std.mem.Allocator;
const types = @import("zigbeam/types.zig");
const writer = @import("zigbeam/writer.zig");

pub const LogLevel = types.LogLevel;
pub const Logger = struct {
    allocator: Allocator,
    fields: std.StringHashMap([]const u8),
    
    pub fn init(allocator: Allocator) Logger {
        return Logger{
            .allocator = allocator,
            .fields = std.StringHashMap([]const u8).init(allocator),
        };
    }

    pub fn deinit(self: *Logger) void {
        var it = self.fields.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            self.allocator.free(entry.value_ptr.*);
        }
        self.fields.deinit();
    }

    pub fn log(self: *Logger, level: LogLevel, message: []const u8) void {
        var entry = types.LogEntry.init(self.allocator);
        defer entry.deinit();

        entry.level = level;
        entry.message = message;

        var it = self.fields.iterator();
        while (it.next()) |kv| {
            const key_dup = self.allocator.dupe(u8, kv.key_ptr.*) catch |e| {
                std.log.err("Failed to duplicate key: {s}", .{@errorName(e)});
                return;
            };
            const value_dup = self.allocator.dupe(u8, kv.value_ptr.*) catch |e| {
                std.log.err("Failed to duplicate value: {s}", .{@errorName(e)});
                self.allocator.free(key_dup);
                return;
            };
            entry.fields.put(key_dup, value_dup) catch |e| {
                std.log.err("Failed to put field: {s}", .{@errorName(e)});
                self.allocator.free(key_dup);
                self.allocator.free(value_dup);
                return;
            };
        }

        writer.writeEntry(&entry) catch |e| {
            std.log.err("Failed to write entry: {s}", .{@errorName(e)});
        };
    }

    pub fn info(self: *Logger, message: []const u8) void {
        self.log(.Info, message);
    }

    pub fn err(self: *Logger, message: []const u8) void {
        self.log(.Error, message);
    }

    pub fn with(self: *Logger, key: []const u8, value: []const u8) Logger {
        var new_logger = Logger.init(self.allocator);
        
        copyFields(self.allocator, &self.fields, &new_logger.fields) catch |e| {
            std.log.err("Failed to copy fields: {s}", .{@errorName(e)});
            return new_logger;
        };

        const key_dup = self.allocator.dupe(u8, key) catch |e| {
            std.log.err("Failed to duplicate key: {s}", .{@errorName(e)});
            return new_logger;
        };
        const value_dup = self.allocator.dupe(u8, value) catch |e| {
            std.log.err("Failed to duplicate value: {s}", .{@errorName(e)});
            self.allocator.free(key_dup);
            return new_logger;
        };
        new_logger.fields.put(key_dup, value_dup) catch |e| {
            std.log.err("Failed to put new field: {s}", .{@errorName(e)});
            self.allocator.free(key_dup);
            self.allocator.free(value_dup);
        };

        return new_logger;
    }

    pub fn withFields(self: *Logger, new_fields: std.StringHashMap([]const u8)) Logger {
        var new_logger = Logger.init(self.allocator);
        
        copyFields(self.allocator, &self.fields, &new_logger.fields) catch |e| {
            std.log.err("Failed to copy fields: {s}", .{@errorName(e)});
            return new_logger;
        };

        var it = new_fields.iterator();
        while (it.next()) |kv| {
            const key_dup = self.allocator.dupe(u8, kv.key_ptr.*) catch |e| {
                std.log.err("Failed to duplicate key: {s}", .{@errorName(e)});
                continue;
            };
            const value_dup = self.allocator.dupe(u8, kv.value_ptr.*) catch |e| {
                std.log.err("Failed to duplicate value: {s}", .{@errorName(e)});
                self.allocator.free(key_dup);
                continue;
            };
            new_logger.fields.put(key_dup, value_dup) catch |e| {
                std.log.err("Failed to put field: {s}", .{@errorName(e)});
                self.allocator.free(key_dup);
                self.allocator.free(value_dup);
            };
        }

        return new_logger;
    }
};

fn copyFields(allocator: Allocator, src: *std.StringHashMap([]const u8), dst: *std.StringHashMap([]const u8)) !void {
    var it = src.iterator();
    while (it.next()) |kv| {
        const key_dup = try allocator.dupe(u8, kv.key_ptr.*);
        errdefer allocator.free(key_dup);
        const value_dup = try allocator.dupe(u8, kv.value_ptr.*);
        errdefer allocator.free(value_dup);
        try dst.put(key_dup, value_dup);
    }
}