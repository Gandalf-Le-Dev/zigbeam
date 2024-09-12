const std = @import("std");
const logger = @import("logger");

fn simulateUserLogin(log: *logger.Logger, username: []const u8) !void {
    var user_logger = try log.with("username", username);
    defer user_logger.deinit();

    try user_logger.info("User login attempt");
    try user_logger.info("User logged in successfully");
    try user_logger.log(.Warn, "this is a warn !");
}

fn processOrder(log: *logger.Logger, order_id: u32, total: f32) !void {
    const order_id_str = try std.fmt.allocPrint(log.allocator, "{d}", .{order_id});
    defer log.allocator.free(order_id_str);
    const total_str = try std.fmt.allocPrint(log.allocator, "{d:.2}", .{total});
    defer log.allocator.free(total_str);

    var new_fields = std.StringHashMap([]const u8).init(log.allocator);
    defer new_fields.deinit();
    try new_fields.put("order_id", order_id_str);
    try new_fields.put("total", total_str);

    var order_logger = try log.withFields(new_fields);
    defer order_logger.deinit();

    try order_logger.info("Processing new order");
    try order_logger.info("Order processed successfully");
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var log = try logger.Logger.init(allocator);
    defer log.deinit();

    try log.info("Application started");

    try simulateUserLogin(&log, "john_doe");
    try processOrder(&log, 12345, 99.99);

    try log.info("Application finished");
}