const std = @import("std");
const builtin = @import("builtin");

const LOAD_AMOUNT = @as(u64, 5e+6);

fn scalarT(comptime T: type, comptime element_count: usize) f64 {
    @setRuntimeSafety(false);
    var arr1: [element_count]T = @splat(0x55);
    var arr2: [element_count]T = @splat(0x55);
    asm volatile (""
        :
        : [_] "r" (&arr1),
          [_] "r" (&arr2),
    );

    for (0..LOAD_AMOUNT) |_| {
        inline for (0..element_count) |i| {
            arr1[i] += arr2[i];
            asm volatile ("" ::: .{ .memory = true });
        }
        inline for (0..element_count) |i| {
            arr1[i] -= arr2[i];
            asm volatile ("" ::: .{ .memory = true });
        }
        inline for (0..element_count) |i| {
            arr1[i] *= arr2[i];
            asm volatile ("" ::: .{ .memory = true });
        }
        inline for (0..element_count) |i| {
            if (T == i64 and builtin.target.cpu.arch.isX86()) {
                var quotient: T = 0;
                asm volatile (
                    \\cqo
                    \\idivq %[divisor]
                    : [_] "={rax}" (quotient),
                    : [dividend] "{rax}" (arr1[i]),
                      [divisor] "r" (arr2[i]),
                    : .{ .rdx = true, .cc = true });
                arr1[i] = quotient;
            } else {
                arr1[i] = @divTrunc(arr1[i], arr2[i]);
            }
            asm volatile ("" ::: .{ .memory = true });
        }
    }

    return @as(f64, element_count * LOAD_AMOUNT * 4) / 1e+6;
}

pub fn INT64(_: usize) f64 {
    return scalarT(i64, 8);
}

pub fn INT32(_: usize) f64 {
    return scalarT(i32, 16);
}

pub fn INT16(_: usize) f64 {
    return scalarT(i16, 32);
}

pub fn FP64(_: usize) f64 {
    return scalarT(f64, 8);
}

pub fn FP32(_: usize) f64 {
    return scalarT(f32, 16);
}

pub fn FP16(_: usize) f64 {
    return scalarT(f16, 32);
}

test "syntax" {
    std.debug.print("\n", .{});
    std.debug.print("INT64.s {}\n", .{INT64(0)});
    std.debug.print("INT32.s {}\n", .{INT32(0)});
    std.debug.print("INT16.s {}\n", .{INT16(0)});
    std.debug.print("\n", .{});
    std.debug.print("FP64.s {}\n", .{FP64(0)});
    std.debug.print("FP32.s {}\n", .{FP32(0)});
    std.debug.print("FP16.s {}\n", .{FP16(0)});
    std.debug.print("\n", .{});
}
