const std = @import("std");
const Allocator = std.mem.Allocator;
const types = @import("zigbeam/types.zig");
const writer = @import("zigbeam/writer.zig");

pub const LogLevel = types.LogLevel;
pub const Logger = struct {
    allocator: Allocator,
    fields: *std.StringHashMap([]const u8),
    
    pub fn init(allocator: Allocator) !Logger {
        const fields = try allocator.create(std.StringHashMap([]const u8));
        fields.* = std.StringHashMap([]const u8).init(allocator);
        return Logger{
            .allocator = allocator,
            .fields = fields,
        };
    }

    pub fn deinit(self: *Logger) void {
        var it = self.fields.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            self.allocator.free(entry.value_ptr.*);
        }
        self.fields.deinit();
        self.allocator.destroy(self.fields);
    }

    pub fn log(self: *Logger, level: LogLevel, message: []const u8) !void {
        var entry = types.LogEntry.init(self.allocator);
        defer entry.deinit();

        entry.level = level;
        entry.message = message;

        var it = self.fields.iterator();
        while (it.next()) |kv| {
            const key_dup = try self.allocator.dupe(u8, kv.key_ptr.*);
            const value_dup = try self.allocator.dupe(u8, kv.value_ptr.*);
            try entry.fields.put(key_dup, value_dup);
        }

        try writer.writeEntry(&entry);
    }

    pub fn info(self: *Logger, message: []const u8) !void {
        try self.log(.Info, message);
    }

    pub fn err(self: *Logger, message: []const u8) !void {
        try self.log(.Error, message);
    }

    pub fn with(self: *Logger, key: []const u8, value: []const u8) !Logger {
        var new_fields = try self.allocator.create(std.StringHashMap([]const u8));
        new_fields.* = std.StringHashMap([]const u8).init(self.allocator);
        
        try copyFields(self.allocator, self.fields, new_fields);

        const key_dup = try self.allocator.dupe(u8, key);
        errdefer self.allocator.free(key_dup);
        const value_dup = try self.allocator.dupe(u8, value);
        errdefer self.allocator.free(value_dup);
        try new_fields.put(key_dup, value_dup);

        return Logger{
            .allocator = self.allocator,
            .fields = new_fields,
        };
    }

    pub fn withFields(self: *Logger, new_fields: std.StringHashMap([]const u8)) !Logger {
        var combined_fields = try self.allocator.create(std.StringHashMap([]const u8));
        combined_fields.* = std.StringHashMap([]const u8).init(self.allocator);
        
        try copyFields(self.allocator, self.fields, combined_fields);

        var it = new_fields.iterator();
        while (it.next()) |kv| {
            const key_dup = try self.allocator.dupe(u8, kv.key_ptr.*);
            errdefer self.allocator.free(key_dup);
            const value_dup = try self.allocator.dupe(u8, kv.value_ptr.*);
            errdefer self.allocator.free(value_dup);
            try combined_fields.put(key_dup, value_dup);
        }

        return Logger{
            .allocator = self.allocator,
            .fields = combined_fields,
        };
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