const std = @import("std");

const LOAD_AMOUNT = @as(usize, 10e+6);

fn vectorT(comptime T: type, comptime vector_amount: usize, comptime garbage: T) f64 {
    @setRuntimeSafety(false);

    var a1: @Vector(vector_amount, T) = @splat(garbage);
    var a2: @Vector(vector_amount, T) = @splat(garbage);
    asm volatile (""
        :
        : [_] "r" (&a1),
          [_] "r" (&a2),
    );

    for (0..LOAD_AMOUNT) |_| {
        a1 *= a2;
        asm volatile ("" ::: .{ .memory = true });
    }

    return @as(f64, vector_amount * LOAD_AMOUNT) / 1e+6;
}

pub fn INT8(_: usize) f64 {
    return vectorT(i8, 128, 0x55);
}

pub fn FP16(_: usize) f64 {
    return vectorT(f16, 64, 0x55);
}

test "syntax" {
    std.debug.print("\n", .{});
    std.debug.print("INT8.AI {}\n", .{INT8(0)});
    std.debug.print("FP16.AI {}\n", .{FP16(0)});
    std.debug.print("\n", .{});
}
