const std = @import("std");
const allocator = @import("allocator.zig");

pub var CPU_COUNT = @as(usize, 1);
pub var MEM_BLOCK_SIZE = @as(usize, 512 << 20);
pub var MEM_BLOCK = std.ArrayList([]u8).empty;

pub fn init() !void {
    if (MEM_BLOCK.items.len == 0) {
        for (0..CPU_COUNT) |_| {
            const mem_block = try allocator.allocAlignFill(MEM_BLOCK_SIZE, 0x55);
            errdefer allocator.free(mem_block);
            try MEM_BLOCK.append(allocator.allocator(), mem_block);
        }
    }
}

pub fn deinit() void {
    if (MEM_BLOCK.items.len > 0) {
        for (MEM_BLOCK.items) |mem|
            allocator.free(mem);
        MEM_BLOCK.deinit(allocator.allocator());
    }
    MEM_BLOCK = .empty;
}

test "syntax" {
    try init();
    deinit();
    try init();
    deinit();
}
