const std = @import("std");
const page_allocator = std.heap.page_allocator;

pub fn allocator() std.mem.Allocator {
    return page_allocator;
}

pub fn alloc(mem_block_size: usize) ![]u8 {
    return try page_allocator.alloc(u8, mem_block_size);
}

pub fn allocFill(mem_block_size: usize, garbage: u8) ![]u8 {
    const mem_block = try alloc(mem_block_size);
    @memset(mem_block, garbage);
    return mem_block;
}

pub fn allocAlign(mem_block_size: usize) ![]u8 {
    return try page_allocator.alignedAlloc(u8, .@"64", mem_block_size);
}

pub fn allocAlignFill(mem_block_size: usize, garbage: u8) ![]u8 {
    const mem_block = try allocAlign(mem_block_size);
    @memset(mem_block, garbage);
    return mem_block;
}

pub fn free(mem: anytype) void {
    page_allocator.free(mem);
}
