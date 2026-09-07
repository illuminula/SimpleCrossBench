const std = @import("std");
const utils = @import("build.utils.zig");

pub fn build(b: *std.Build) !void {
    b.install_path = "./bin/";
    try utils.addBin(b, "benchcpu", "./src/benchcpu.zig", &utils.popular_targets, .ReleaseFast);
    try utils.addBin(b, "benchmem", "./src/benchmem.zig", &utils.popular_targets, .ReleaseFast);
}
