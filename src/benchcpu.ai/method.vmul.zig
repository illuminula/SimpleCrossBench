const std = @import("std");

const LOAD_AMOUNT = @as(usize, 1e+7);

fn vectorT(comptime T: type, comptime vector_amount: usize) f64 {
    @setRuntimeSafety(false);
    var a1: @Vector(vector_amount, T) = @splat(0x55);
    var a2: @Vector(vector_amount, T) = @splat(0x55);
    asm volatile (""
        :
        : [_] "r" (&a1),
          [_] "r" (&a2),
    );

    for (0..LOAD_AMOUNT) |_| {
        a1 *= a2;
        asm volatile ("" ::: .{ .memory = true });
    }

    return @as(f64, vector_amount * LOAD_AMOUNT) / 1e+9;
}

pub fn INT8(_: usize) f64 {
    return vectorT(i8, 512);
}

pub fn FP16(_: usize) f64 {
    return vectorT(f16, 256);
}

test "syntax" {
    std.debug.print("\n", .{});
    std.debug.print("INT8.AI {}\n", .{INT8(0)});
    std.debug.print("FP16.AI {}\n", .{FP16(0)});
    std.debug.print("\n", .{});
}
