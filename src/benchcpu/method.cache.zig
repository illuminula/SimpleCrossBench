const std = @import("std");
const builtin = @import("builtin");
const allocator = std.heap.smp_allocator;

const LOAD_AMOUNT = @as(u64, 1e+6);

fn cacheT(comptime buf_size: usize) f64 {
    var buf: [buf_size / 1024]@Vector(1024, u8) align(64) = @splat(@splat(0x55));
    asm volatile (""
        :
        : [_] "r" (&buf),
    );

    const load_amount = LOAD_AMOUNT / ((buf_size >> 10) / 16);
    for (0..load_amount) |_| {
        for (0..buf.len) |i| {
            buf[i] = @splat(0x55);
            asm volatile ("" ::: .{ .memory = true });
        }
        asm volatile ("" ::: .{ .memory = true });
    }

    return @as(f64, @floatFromInt((load_amount * buf_size) >> 10)) / 1e+6;
}

pub fn INT16K(_: usize) f64 {
    return cacheT(16 << 10);
}

pub fn INT192K(_: usize) f64 {
    return cacheT(192 << 10);
}

pub fn INT4M(_: usize) f64 {
    return cacheT(4 << 20);
}

pub fn INT12M(_: usize) f64 {
    if (builtin.os.tag == .linux)
        _ = std.os.linux.setrlimit(.STACK, &.{ .cur = 16 << 20, .max = 16 << 20 });
    return cacheT(12 << 20);
}

test "syntax" {
    std.debug.print("\n", .{});
    std.debug.print("INT16K  {}\n", .{INT16K(0)});
    std.debug.print("INT192K {}\n", .{INT192K(0)});
    std.debug.print("INT4M   {}\n", .{INT4M(0)});
    std.debug.print("INT16M  {}\n", .{INT12M(0)});
    std.debug.print("\n", .{});
}
