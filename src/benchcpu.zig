const std = @import("std");
const qstdio = @import("./shared/QuickStdio.zig");
const QuickBench = @import("./shared/QuickBench.zig");
const method = @import("./benchcpu/method.zig");

pub fn main() !void {
    const cpu_count = std.Thread.getCpuCount() catch 1;

    qstdio.initGlobal();
    defer qstdio.deinitGlobal();

    var qb = QuickBench.init(cpu_count, 2500, 14);
    defer qb.deinit();

    const headers_int = [_][]const u8{
        "INT64.s", "INT64.v",
        "INT32.s", "INT32.v",
        "INT16.s", "INT16.v",
    };
    const funcs_int = [_]QuickBench.UserCallback{
        method.scalar.INT64, method.vector.INT64,
        method.scalar.INT32, method.vector.INT32,
        method.scalar.INT16, method.vector.INT16,
    };
    try qb.bench(&headers_int, &funcs_int, "MOps");
    try qstdio.writeLine("", .{});

    const headers_fp = [_][]const u8{
        "FP64.s", "FP64.v",
        "FP32.s", "FP32.v",
        "FP16.s", "FP16.v",
    };
    const funcs_fp = [_]QuickBench.UserCallback{
        method.scalar.FP64, method.vector.FP64,
        method.scalar.FP32, method.vector.FP32,
        method.scalar.FP16, method.vector.FP16,
    };
    try qb.bench(&headers_fp, &funcs_fp, "MOps");
    try qstdio.writeLine("", .{});

    const headers_ai = [_][]const u8{
        "INT8.AI", "FP16.AI",
    };
    const funcs_ai = [_]QuickBench.UserCallback{
        method.ai.INT8, method.ai.FP16,
    };
    try qb.bench(&headers_ai, &funcs_ai, "MOps");
    try qstdio.writeLine("", .{});

    qstdio.autoPause();
}
