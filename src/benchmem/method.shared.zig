const std = @import("std");
const allocator = @import("allocator.zig");
const smp_allocator = std.heap.smp_allocator;

pub var CPU_COUNT = @as(usize, 1);
pub var MEM_BLOCKS: [][]u8 = &.{};
pub var MEM_BLOCK_SIZE = @as(usize, 512 << 20);
pub var MEM_BLOCK_RANDOM_INDEXES: []usize = &.{};

fn taskAlloc(mem_block: *[]u8) void {
    mem_block.* = allocator.allocAlignFill(MEM_BLOCK_SIZE, 0x55) catch @as([]u8, &.{});
}

pub fn init() !void {
    if (MEM_BLOCKS.len == 0) {
        var io_thread = std.Io.Threaded.init(smp_allocator, .{});
        defer io_thread.deinit();
        const io = io_thread.io();
        var group = std.Io.Group.init;
        errdefer group.cancel(io);

        MEM_BLOCKS = try smp_allocator.alloc([]u8, CPU_COUNT);
        errdefer smp_allocator.free(MEM_BLOCKS);
        for (0..CPU_COUNT) |i|
            group.async(io, taskAlloc, .{&MEM_BLOCKS[i]});
        try group.await(io);
    }
}

pub fn deinit() void {
    if (MEM_BLOCKS.len > 0) {
        for (MEM_BLOCKS) |mem|
            allocator.free(mem);
        allocator.free(MEM_BLOCKS);
    }
    MEM_BLOCKS = &.{};
}

test "syntax" {
    std.debug.print("\n", .{});
    try init();
    for (0..CPU_COUNT) |i|
        std.debug.print("CPU{:<3} {}MB\n", .{ i, MEM_BLOCKS[i].len >> 20 });
    deinit();
    try init();
    for (0..CPU_COUNT) |i|
        std.debug.print("CPU{:<3} {}MB\n", .{ i, MEM_BLOCKS[i].len >> 20 });
    deinit();
    std.debug.print("\n", .{});
}
