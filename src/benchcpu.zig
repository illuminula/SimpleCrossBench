const std = @import("std");
const qstdio = @import("./shared/QuickStdio.zig");
const QuickBench = @import("./shared/QuickBench.zig");
const method = @import("./benchcpu/method.zig");

pub fn main() !void {
    const cpu_count = std.Thread.getCpuCount() catch 1;

    qstdio.initGlobal();
    defer qstdio.deinitGlobal();

    var qb = QuickBench.init(cpu_count, 2500, 10 + 1 + 4);
    defer qb.deinit();

    const headers_int_scalar = [_][]const u8{
        "INT64.s", "INT32.s", "INT16.s", "INT8.s",
    };
    const headers_int_vector = [_][]const u8{
        "INT64.v", "INT32.v", "INT16.v", "INT8.v",
    };
    const funcs_int_scalar = [_]QuickBench.BenchFunc{
        method.scalar.INT64, method.scalar.INT32, method.scalar.INT16, method.scalar.INT8,
    };
    const funcs_int_vector = [_]QuickBench.BenchFunc{
        method.vector.INT64, method.vector.INT32, method.vector.INT16, method.vector.INT8,
    };
    try qb.bench(&headers_int_scalar, &funcs_int_scalar, "MOps");
    try qstdio.writeLine("", .{});
    try qb.bench(&headers_int_vector, &funcs_int_vector, "MOps");
    try qstdio.writeLine("", .{});

    const headers_fp_scalar = [_][]const u8{
        "FP64.s", "FP32.s", "FP16.s",
    };
    const headers_fp_vector = [_][]const u8{
        "FP64.v", "FP32.v", "FP16.v",
    };
    const funcs_fp_scalar = [_]QuickBench.BenchFunc{
        method.scalar.FP64, method.scalar.FP32, method.scalar.FP16,
    };
    const funcs_fp_vector = [_]QuickBench.BenchFunc{
        method.vector.FP64, method.vector.FP32, method.vector.FP16,
    };
    try qb.bench(&headers_fp_scalar, &funcs_fp_scalar, "MOps");
    try qstdio.writeLine("", .{});
    try qb.bench(&headers_fp_vector, &funcs_fp_vector, "MOps");
    try qstdio.writeLine("", .{});

    const headers_cache = [_][]const u8{
        "L1C 16K ", "L2C 192K", "L3C 3M  ", "L4C 12M ",
    };
    const funcs_cache = [_]QuickBench.BenchFunc{
        method.cache.INT16K, method.cache.INT192K, method.cache.INT3M, method.cache.INT12M,
    };
    try qb.bench(&headers_cache, &funcs_cache, "GBps");
    try qstdio.writeLine("", .{});

    qstdio.autoPause();
}
