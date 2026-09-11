const QuickBench = @This();
const std = @import("std");
const builtin = @import("builtin");
const qstdio = @import("./QuickStdio.zig");
const allocator = std.heap.smp_allocator;

cpu_count: usize,
bench_time_ms: u32,
bench_item_width: u32,
threaded: std.Io.Threaded,

pub fn init(cpu_count: usize, bench_time_ms: u32, bench_item_width: u32) QuickBench {
    return .{
        .cpu_count = cpu_count,
        .bench_time_ms = bench_time_ms,
        .bench_item_width = bench_item_width,
        .threaded = .init(allocator, .{}),
    };
}

pub fn deinit(self: *QuickBench) void {
    self.threaded.deinit();
}

fn currentNs(self: *QuickBench) i96 {
    return std.Io.Timestamp.now(self.threaded.io(), .real).toNanoseconds();
}

fn currentMs(self: *QuickBench) i64 {
    return std.Io.Timestamp.now(self.threaded.io(), .real).toMilliseconds();
}

fn toPerSecScore(ns1: i96, origin_score: f64, ns2: i96) f64 {
    return origin_score / (@as(f64, @floatFromInt(ns2 - ns1)) / 1e+9);
}

pub fn printSplit(self: *QuickBench, count: u32) !void {
    try qstdio.write("+", .{});
    for (0..count) |_| {
        try qstdio.write("{s:-<[1]}+", .{ "", self.bench_item_width });
    }
    try qstdio.writeLine("", .{});
}

pub fn printHeader(self: *QuickBench, items: []const []const u8) !void {
    try qstdio.write("|", .{});
    for (items) |item|
        try qstdio.write("{s:<[1]}|", .{ item, self.bench_item_width });
    try qstdio.writeLine("", .{});
}

pub const BenchFunc = *const fn (usize) f64;

fn placedCallback(func: BenchFunc, cpu_index: usize, result: *f64) void {
    const arch_bit_size = @bitSizeOf(usize);
    const cpu_group = cpu_index / arch_bit_size;
    const cpu_bit = @as(usize, 1) << @truncate(cpu_index % arch_bit_size);

    if (builtin.os.tag == .windows) {
        const c = @cImport({
            @cInclude("windows.h");
        });
        const affinity = c.GROUP_AFFINITY{ .Group = @truncate(cpu_group), .Mask = cpu_bit };
        _ = c.SetThreadGroupAffinity(c.GetCurrentThread(), &affinity, null);
    } else if (builtin.os.tag == .linux) {
        var cpuset: std.os.linux.cpu_set_t = @splat(0);
        cpuset[cpu_group] |= cpu_bit;
        std.os.linux.sched_setaffinity(0, &cpuset) catch {};
    }

    result.* = func(cpu_index);
}

fn batchRun(self: *QuickBench, func: BenchFunc, cpu_indexes: []const usize) !f64 {
    const io = self.threaded.io();
    var group = std.Io.Group.init;
    errdefer group.cancel(io);
    var results = try allocator.alloc(f64, cpu_indexes.len);
    defer allocator.free(results);

    var score = @as(f64, 0.0);
    const ns1 = self.currentNs();
    for (0..cpu_indexes.len) |i|
        group.async(io, placedCallback, .{ func, cpu_indexes[i], &results[i] });
    try group.await(io);
    for (0..cpu_indexes.len) |i|
        score += results[i];
    const ns2 = self.currentNs();

    return toPerSecScore(ns1, score, ns2);
}

pub fn bench(self: *QuickBench, comptime header: []const []const u8, funcs: []const BenchFunc, unit: []const u8) !void {
    try self.printSplit(1 + header.len);
    try self.printHeader(&[_][]const u8{"CPU"} ++ header);
    try self.printSplit(1 + header.len);

    var cpu_indexes_arr = std.ArrayList([]const usize).empty;
    defer cpu_indexes_arr.deinit(allocator);

    try cpu_indexes_arr.append(allocator, &.{0});
    if (self.cpu_count > 2)
        try cpu_indexes_arr.append(allocator, &.{self.cpu_count / 2});
    try cpu_indexes_arr.append(allocator, &.{self.cpu_count - 1});
    var cpu_indexes_allcpu = try allocator.alloc(usize, self.cpu_count);
    defer allocator.free(cpu_indexes_allcpu);
    for (0..self.cpu_count) |i|
        cpu_indexes_allcpu[i] = i;
    try cpu_indexes_arr.append(allocator, cpu_indexes_allcpu);

    for (cpu_indexes_arr.items) |cpu_indexes| {
        try qstdio.write("|", .{});
        if (cpu_indexes.len == self.cpu_count) {
            try qstdio.write("0-{d:<3}", .{self.cpu_count - 1});
            try qstdio.write("{s:<[1]}", .{ "", @max(1, self.bench_item_width - 2 - 3) });
        } else {
            for (cpu_indexes) |i|
                try qstdio.write("{d:<3}", .{i});
            try qstdio.write("{s:<[1]}", .{ "", @max(1, self.bench_item_width - 3 * cpu_indexes.len) });
        }

        for (funcs) |func| {
            try qstdio.write("|{s:<[1]}", .{ "", self.bench_item_width });

            const ms = self.currentMs();
            while (self.currentMs() - ms < self.bench_time_ms) {
                const score = try self.batchRun(func, cpu_indexes);
                for (0..self.bench_item_width) |_|
                    try qstdio.write("\x08", .{});
                try qstdio.write("{d:<[1].1} {[2]s}", .{ score, self.bench_item_width - 1 - unit.len, unit });
            }

            try qstdio.write("|\x08", .{});
        }

        try qstdio.writeLine("", .{});
    }

    try self.printSplit(1 + header.len);
}

fn _test_callback(_: usize) f64 {
    var io_thread = std.Io.Threaded.init_single_threaded;
    defer io_thread.deinit();
    const io = io_thread.io();

    io.sleep(.fromMilliseconds(100), .awake) catch {};
    return 1.0;
}

test "syntax" {
    qstdio.initGlobal();
    defer qstdio.deinitGlobal();
    qstdio.redirectStderr();
    try qstdio.writeLine("", .{});

    var qb = QuickBench.init(std.Thread.getCpuCount() catch 1, 100, 13);
    defer qb.deinit();

    const headers = [_][]const u8{ "8", "32", "64" };
    const funcs = [_]BenchFunc{ _test_callback, _test_callback, _test_callback };
    try qb.bench(&headers, &funcs, "MOps");
}
