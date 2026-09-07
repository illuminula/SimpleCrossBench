const std = @import("std");
const builtin = @import("builtin");
const QuickStdio = @This();

var threaded: std.Io.Threaded = undefined;
var io: std.Io = undefined;
var reader_buf: [4 << 10]u8 = undefined;
var writer_buf: [4 << 10]u8 = undefined;
var reader: std.Io.File.Reader = undefined;
var writer: std.Io.File.Writer = undefined;

pub fn initGlobal() void {
    threaded = .init(std.heap.smp_allocator, .{});
    io = threaded.io();
    reader_buf = @splat(0);
    writer_buf = @splat(0);
    reader = std.Io.File.stdin().reader(io, &reader_buf);
    writer = std.Io.File.stdout().writer(io, &writer_buf);
}

pub fn deinitGlobal() void {
    threaded.deinit();
    threaded = undefined;
    io = undefined;
    reader_buf = undefined;
    writer_buf = undefined;
    reader = undefined;
    writer = undefined;
}

fn trimCRLF(buf: *[]u8) void {
    if (buf.*.len > 0 and buf.*[buf.*.len - 1] == '\r')
        buf.* = buf.*[0 .. buf.*.len - 1];
}

pub fn readByte() !u8 {
    return try reader.interface.takeByte();
}

pub fn readLine() ![]u8 {
    var line: []u8 = try reader.interface.takeDelimiter('\n') orelse "";
    trimCRLF(&line);
    return line;
}

pub fn discardInput() !void {
    try reader.interface.discardRemaining();
}

pub fn write(comptime fmt: []const u8, args: anytype) !void {
    try writer.interface.print(fmt, args);
    try writer.flush();
}

pub fn writeLine(comptime fmt: []const u8, args: anytype) !void {
    try write(fmt ++ "\n", args);
    try writer.flush();
}

pub fn redirectStdout() void {
    writer = std.Io.File.stdout().writer(io, &writer_buf);
}

pub fn redirectStderr() void {
    writer = std.Io.File.stderr().writer(io, &writer_buf);
}

pub fn autoPause() void {
    if (builtin.os.tag == .windows)
        _ = readByte() catch {};
}

test "syntax" {
    QuickStdio.initGlobal();
    defer QuickStdio.deinitGlobal();

    // _ = try QuickStdio.readLine();
    try QuickStdio.writeLine("", .{});
    try QuickStdio.write("1", .{});
    try QuickStdio.writeLine("2", .{});
    try QuickStdio.write("3", .{});
    try QuickStdio.writeLine("", .{});
    QuickStdio.redirectStderr();
    try QuickStdio.writeLine("", .{});
    try QuickStdio.write("4", .{});
    try QuickStdio.writeLine("5", .{});
    try QuickStdio.write("6", .{});
    try QuickStdio.writeLine("", .{});
}
