const std = @import("std");
const allocator = @import("allocator.zig");
const shared = @import("method.shared.zig");

fn writeT(comptime vector_count: usize, mem_block: []u8) f64 {
    @setRuntimeSafety(false);

    const mem_block_size = mem_block.len / vector_count;
    const ptr = @as([*]@Vector(vector_count, u8), @ptrCast(@alignCast(mem_block.ptr)));
    for (0..mem_block_size) |i| {
        ptr[i] = @splat(0xcc);
        asm volatile ("" ::: .{ .memory = true });
    }

    return @as(f64, @floatFromInt(mem_block.len >> 20)) / 1024.0;
}

pub fn INT8(_: usize) f64 {
    const mem_block = allocator.allocAlign(shared.MEM_BLOCK_SIZE) catch @as([]u8, &.{});
    defer allocator.free(mem_block);
    return writeT(1, mem_block);
}

pub fn INT32(_: usize) f64 {
    const mem_block = allocator.allocAlign(shared.MEM_BLOCK_SIZE) catch @as([]u8, &.{});
    defer allocator.free(mem_block);
    return writeT(4, mem_block);
}

pub fn INT64(_: usize) f64 {
    const mem_block = allocator.allocAlign(shared.MEM_BLOCK_SIZE) catch @as([]u8, &.{});
    defer allocator.free(mem_block);
    return writeT(8, mem_block);
}

pub fn INT256(_: usize) f64 {
    const mem_block = allocator.allocAlign(shared.MEM_BLOCK_SIZE) catch @as([]u8, &.{});
    defer allocator.free(mem_block);
    return writeT(32, mem_block);
}

pub fn INT512(_: usize) f64 {
    const mem_block = allocator.allocAlign(shared.MEM_BLOCK_SIZE) catch @as([]u8, &.{});
    defer allocator.free(mem_block);
    return writeT(64, mem_block);
}

pub fn INT1024(_: usize) f64 {
    const mem_block = allocator.allocAlign(shared.MEM_BLOCK_SIZE) catch @as([]u8, &.{});
    defer allocator.free(mem_block);
    return writeT(128, mem_block);
}

test "syntax" {
    std.debug.print("\n", .{});
    std.debug.print("8bit    {}\n", .{INT8(0)});
    std.debug.print("32bit   {}\n", .{INT32(0)});
    std.debug.print("64bit   {}\n", .{INT64(0)});
    std.debug.print("256bit  {}\n", .{INT256(0)});
    std.debug.print("512bit  {}\n", .{INT512(0)});
    std.debug.print("1024bit {}\n", .{INT1024(0)});
    std.debug.print("\n", .{});
}
