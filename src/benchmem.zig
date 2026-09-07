const std = @import("std");
const qstdio = @import("./shared/QuickStdio.zig");
const QuickBench = @import("./shared/QuickBench.zig");
const method = @import("./benchmem/method.zig");

pub fn main(init: std.process.Init) !void {
    const cmd_args = try init.minimal.args.toSlice(init.arena.allocator());
    if (cmd_args.len > 1)
        method.shared.MEM_BLOCK_SIZE = @max(1, (std.fmt.parseInt(usize, cmd_args[1], 10) catch 1)) << 20;
    method.shared.CPU_COUNT = std.Thread.getCpuCount() catch 1;

    qstdio.initGlobal();
    defer qstdio.deinitGlobal();

    var qb = QuickBench.init(2500, 13);
    defer qb.deinit();

    const headers_read = [_][]const u8{
        "Read 8bit",   "Read 32bit",  "Read 64bit",
        "Read 256bit", "Read 512bit", "Read 1024bit",
    };
    const funcs_read = [_]QuickBench.UserCallback{
        method.read.INT8,   method.read.INT32,  method.read.INT64,
        method.read.INT256, method.read.INT512, method.read.INT1024,
    };
    try method.shared.init();
    try qb.bench(&headers_read, &funcs_read, "GBps");
    try qstdio.writeLine("", .{});
    method.shared.deinit();

    const headers_write = [_][]const u8{
        "Write 8bit",   "Write 32bit",  "Write 64bit",
        "Write 256bit", "Write 512bit", "Write 1024bit",
    };
    const funcs_write = [_]QuickBench.UserCallback{
        method.write.INT8,   method.write.INT32,  method.write.INT64,
        method.write.INT256, method.write.INT512, method.write.INT1024,
    };
    try method.shared.init();
    try qb.bench(&headers_write, &funcs_write, "GBps");
    try qstdio.writeLine("", .{});
    method.shared.deinit();

    const headers_copy = [_][]const u8{
        "Copy 8bit",   "Copy 32bit",  "Copy 64bit",
        "Copy 256bit", "Copy 512bit", "Copy 1024bit",
    };
    const funcs_copy = [_]QuickBench.UserCallback{
        method.copy.INT8,   method.copy.INT32,  method.copy.INT64,
        method.copy.INT256, method.copy.INT512, method.copy.INT1024,
    };
    try method.shared.init();
    try qb.bench(&headers_copy, &funcs_copy, "GBps");
    try qstdio.writeLine("", .{});
    method.shared.deinit();

    const headers_alloc = [_][]const u8{
        "Alloc 8bit",   "Alloc 32bit",  "Alloc 64bit",
        "Alloc 256bit", "Alloc 512bit", "Alloc 1024bit",
    };
    const funcs_alloc = [_]QuickBench.UserCallback{
        method.alloc.INT8,   method.alloc.INT32,  method.alloc.INT64,
        method.alloc.INT256, method.alloc.INT512, method.alloc.INT1024,
    };
    try qb.bench(&headers_alloc, &funcs_alloc, "GBps");
    try qstdio.writeLine("", .{});

    qstdio.autoPause();
}
