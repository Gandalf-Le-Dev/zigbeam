# Zigbeam
Structured Logging library for the Zig language

## How to use

1. You can fetch Zigbeam with this command
   
   ```cmd
   zig fetch --save=zigbeam git+https://github.com/Gandalf-Le-Dev/zigbeam/#HEAD
   ```

   It will fetch the master version. If you wish to fetch a specific version, replace `#HEAD` with the commit hash.

3. Then in your build.zig you must add: 

```zig
const zigbeam_dep = b.dependency("zigbeam", .{});
const zigbeam_mod = zigbeam_dep.module("zigbeam");
exe.root_module.addImport("zigbeam", zigbeam_mod);
```
