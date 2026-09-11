const std = @import("std");

const LOAD_AMOUNT = @as(u64, 4e+6);

fn vectorT(comptime T: type, comptime element_count: usize) f64 {
    @setRuntimeSafety(false);
    var a1: @Vector(element_count, T) = @splat(0x55);
    var a2: @Vector(element_count, T) = @splat(0x55);
    asm volatile (""
        :
        : [_] "r" (&a1),
          [_] "r" (&a2),
    );

    for (0..LOAD_AMOUNT) |_| {
        a1 += a2;
        asm volatile ("" ::: .{ .memory = true });
        a1 -= a2;
        asm volatile ("" ::: .{ .memory = true });
        a1 *= a2;
        asm volatile ("" ::: .{ .memory = true });
        a1 = @divTrunc(a1, a2);
        asm volatile ("" ::: .{ .memory = true });
    }

    return @as(f64, element_count * LOAD_AMOUNT * 4) / 1e+6;
}

pub fn INT64(_: usize) f64 {
    return vectorT(i64, 16);
}

pub fn INT32(_: usize) f64 {
    return vectorT(i32, 32);
}

pub fn INT16(_: usize) f64 {
    return vectorT(i16, 64);
}

pub fn INT8(_: usize) f64 {
    return vectorT(i8, 64);
}

pub fn FP64(_: usize) f64 {
    return vectorT(f64, 16);
}

pub fn FP32(_: usize) f64 {
    return vectorT(f32, 32);
}

pub fn FP16(_: usize) f64 {
    return vectorT(f16, 64);
}

test "syntax" {
    std.debug.print("\n", .{});
    std.debug.print("INT64.v {}\n", .{INT64(0)});
    std.debug.print("INT32.v {}\n", .{INT32(0)});
    std.debug.print("INT16.v {}\n", .{INT16(0)});
    std.debug.print("\n", .{});
    std.debug.print("FP64.v {}\n", .{FP64(0)});
    std.debug.print("FP32.v {}\n", .{FP32(0)});
    std.debug.print("FP16.v {}\n", .{FP16(0)});
    std.debug.print("\n", .{});
}
