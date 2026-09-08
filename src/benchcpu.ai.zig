const std = @import("std");
const qstdio = @import("./shared/QuickStdio.zig");
const QuickBench = @import("./shared/QuickBench.zig");
const method = @import("./benchcpu.ai/method.zig");

pub fn main() !void {
    const cpu_count = std.Thread.getCpuCount() catch 1;

    qstdio.initGlobal();
    defer qstdio.deinitGlobal();

    var qb = QuickBench.init(cpu_count, 2500, 13);
    defer qb.deinit();

    const headers_ai = [_][]const u8{
        "INT8.AI", "FP16.AI",
    };
    const funcs_ai = [_]QuickBench.UserCallback{
        method.ai.INT8, method.ai.FP16,
    };
    try qb.bench(&headers_ai, &funcs_ai, "GOps");
    try qstdio.writeLine("", .{});

    qstdio.autoPause();
}
