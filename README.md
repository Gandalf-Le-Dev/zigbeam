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
    exe.root_module.addImport("zigbeam", zigbeam_mod);
    ```

3. You can now use Zigbeam in your project. Here is an example:

    ```zig
    const std = @import("std");
    const zigbeam = @import("zigbeam");

    pub fn main() !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();

        var log = try zigbeam.Logger.init(allocator);
        defer log.deinit();

        try log.info("Zigbeam is working!");
    }
    ```
