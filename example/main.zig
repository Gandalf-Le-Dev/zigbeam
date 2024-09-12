const std = @import("std");
const Logger = @import("zigbeam").Logger;

fn simulateUserLogin(log: *Logger, username: []const u8) void {
    var user_logger = log.with("username", username);
    defer user_logger.deinit();

    user_logger.info("User login attempt");
    user_logger.info("User logged in successfully");
    user_logger.log(.Warn, "This is a warning!");
}

fn processOrder(log: *Logger, order_id: u32, total: f32) void {
    const order_id_str = std.fmt.allocPrint(log.allocator, "{d}", .{order_id}) catch {
        log.err("Failed to allocate order_id string");
        return;
    };
    defer log.allocator.free(order_id_str);
    
    const total_str = std.fmt.allocPrint(log.allocator, "{d:.2}", .{total}) catch {
        log.err("Failed to allocate total string");
        return;
    };
    defer log.allocator.free(total_str);

    var new_fields = std.StringHashMap([]const u8).init(log.allocator);
    defer new_fields.deinit();
    new_fields.put("order_id", order_id_str) catch {
        log.err("Failed to put order_id field");
        return;
    };
    new_fields.put("total", total_str) catch {
        log.err("Failed to put total field");
        return;
    };

    var order_logger = log.withFields(new_fields);
    defer order_logger.deinit();

    order_logger.info("Processing new order");
    order_logger.info("Order processed successfully");
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var log = Logger.init(allocator);
    defer log.deinit();

    log.info("Application started");

    simulateUserLogin(&log, "john_doe");
    processOrder(&log, 12345, 99.99);

    log.info("Application finished");
}