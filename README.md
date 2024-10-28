# Error I am getting

    ```zig
    run
    └─ run zigbeam
    └─ zig build-exe zigbeam Debug native 1 errors
    src/zigbeam.zig:186:39: error: unable to evaluate comptime expression
                self.logger.formatLog(self.scope, .info, format, args, source_location);
                                    ~~~~^~~~~~
    referenced by:
        main: src/main.zig:22:16
        callMain: /Users/gandalfledev/Library/Application Support/Code/User/globalStorage/ziglang.vscode-zig/zig_install/lib/std/start.zig:514:17
        remaining reference traces hidden; use '-freference-trace' to see all reference traces
    error: the following command failed with 1 compilation errors:
    /Users/gandalfledev/Library/Application Support/Code/User/globalStorage/ziglang.vscode-zig/zig_install/zig build-exe -ODebug --dep aurora --dep zigbeam -Mroot=/Users/gandalfledev/Developer/zigbeam/src/main.zig -Maurora=/Users/gandalfledev/Developer/aurora/src/aurora.zig --dep aurora -Mzigbeam=/Users/gandalfledev/Developer/zigbeam/src/zigbeam.zig --cache-dir /Users/gandalfledev/Developer/zigbeam/.zig-cache --global-cache-dir /Users/gandalfledev/.cache/zig --name zigbeam --listen=- 
    Build Summary: 0/3 steps succeeded; 1 failed (disable with --summary none)
    run transitive failure
    └─ run zigbeam transitive failure
    └─ zig build-exe zigbeam Debug native 1 errors
    error: the following build command failed with exit code 1:
    /Users/gandalfledev/Developer/zigbeam/.zig-cache/o/3663f7e64f130b6c0025d2f923d9d94e/build /Users/gandalfledev/Library/Application Support/Code/User/globalStorage/ziglang.vscode-zig/zig_install/zig /Users/gandalfledev/Developer/zigbeam /Users/gandalfledev/Developer/zigbeam/.zig-cache /Users/gandalfledev/.cache/zig --seed 0xa83eff5f -Z0765ad75bdf6a3b4 run
    ```
    