const std = @import("std");
const Logger = @import("zigbeam");

// Example usage
pub fn main() !void {
    std.log.debug("Debug message: {s}", .{"test"});
    std.log.info("Info message: {s}", .{"test"});
    std.log.warn("Warning message: {s}", .{"test"});
    std.log.err("Error message: {s}", .{"test"});

    // You can also use the scoped logger
    const log = std.log.scoped(.my_project);
    log.debug("Debug message: {s}", .{"test"});
    log.info("Info message: {s}", .{"test"});
    log.warn("Warning message: {s}", .{"test"});
    log.err("Error message: {s}", .{"test"});
}

pub const std_options = std.Options{
    // Set the log level to info
    .log_level = .debug,
    .logFn = Logger.defaultLog,
};
