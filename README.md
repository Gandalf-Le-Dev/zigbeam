# Zigbeam

Structured Logging library for the Zig language

## How to use

1. You can fetch Zigbeam with this command

   ```cmd
   zig fetch --save=zigbeam git+https://github.com/Gandalf-Le-Dev/zigbeam/#HEAD
   ```

   It will fetch the master version. If you wish to fetch a specific version, replace `#HEAD` with the commit hash.

2. Then in your build.zig you must add:

    ```zig
    const zigbeam_dep = b.dependency("zigbeam", .{});
    const zigbeam_mod = zigbeam_dep.module("zigbeam");
    exe_or_lib.root_module.addImport("zigbeam", zigbeam_mod);
    ```

3. You can now use Zigbeam in your project. Here is an [example](/src/main.zig):

    ```zig
    const std = @import("std");
    const Logger = @import("zigbeam").Logger;

    // Example usage
    pub fn main() void {
        // Create a logger with default config
        var log = Logger.init(.{
            .allocator = std.heap.page_allocator,
            .detect_no_color = false,
            .include_source_location = true,
            .show_timestamp = true,
            .timestamp_format = .standard,
        }) catch unreachable;
        defer log.deinit();

        // Use the logger
        log.debug("Debug message: {s}", .{"test"}, @src());
        log.info("Info message with value: {d}", .{42}, @src());
        log.warn("Warning message", .{}, @src());
        log.err("Error occurred: {s}", .{"something went wrong"}, @src());
    }

    pub const std_options = .{
        // Set the log level to info
        .log_level = .debug,
    };
    ```

    The available timestamp formats are:

    - `standard`: DD-MM-YYYY HH:MM:SS
    - `iso8601`: YYYY-MM-DD HH:MM:SS
    - `unix`: Unix timestamp
    - `rfc3339`: YYYY-MM-DDThh:mm:ssZ
    - `compact`: HH:MM:SS.mmm

## Dependencies

- [Aurora](https://github.com/Gandalf-Le-Dev/aurora)

## Screenshots

![Zigbeam](/img/SCR-20241026-urdd.png)
