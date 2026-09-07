const std = @import("std");
const allocator = @import("allocator.zig");
const shared = @import("method.shared.zig");

fn copyT(comptime vector_count: usize, mem_block: []u8) f64 {
    const mem_block_size = mem_block.len / vector_count / 2;
    const ptr1 = @as([*]@Vector(vector_count, u8), @ptrCast(@alignCast(mem_block.ptr)));
    const ptr2 = ptr1 + mem_block_size;

    for (0..mem_block_size) |i| {
        ptr1[i] = ptr2[i];
        asm volatile ("" ::: .{ .memory = true });
    }

    return @as(f64, @floatFromInt(mem_block.len >> 20)) / 1024.0;
}

pub fn INT8(cpu_index: usize) f64 {
    return copyT(1, shared.MEM_BLOCK.items[cpu_index]);
}

pub fn INT32(cpu_index: usize) f64 {
    return copyT(4, shared.MEM_BLOCK.items[cpu_index]);
}

pub fn INT64(cpu_index: usize) f64 {
    return copyT(8, shared.MEM_BLOCK.items[cpu_index]);
}

pub fn INT256(cpu_index: usize) f64 {
    return copyT(32, shared.MEM_BLOCK.items[cpu_index]);
}

pub fn INT512(cpu_index: usize) f64 {
    return copyT(64, shared.MEM_BLOCK.items[cpu_index]);
}

pub fn INT1024(cpu_index: usize) f64 {
    return copyT(128, shared.MEM_BLOCK.items[cpu_index]);
}

test "syntax" {
    try shared.init();
    defer shared.deinit();

    std.debug.print("\n", .{});
    std.debug.print("8bit    {}\n", .{INT8(0)});
    std.debug.print("32bit   {}\n", .{INT32(0)});
    std.debug.print("64bit   {}\n", .{INT64(0)});
    std.debug.print("256bit  {}\n", .{INT256(0)});
    std.debug.print("512bit  {}\n", .{INT512(0)});
    std.debug.print("1024bit {}\n", .{INT1024(0)});
    std.debug.print("\n", .{});
}
