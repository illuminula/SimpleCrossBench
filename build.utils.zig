const std = @import("std");

pub const popular_targets = [_]std.Target.Query{
    .{ .os_tag = .windows, .cpu_arch = .x86_64, .cpu_model = .baseline },
    .{ .os_tag = .windows, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64_v3 } },
    .{ .os_tag = .windows, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.znver4 } },
    .{ .os_tag = .windows, .cpu_arch = .aarch64, .cpu_model = .baseline },

    .{ .os_tag = .linux, .cpu_arch = .x86_64, .cpu_model = .baseline },
    .{ .os_tag = .linux, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64_v3 } },
    .{ .os_tag = .linux, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.znver4 } },
    .{ .os_tag = .linux, .cpu_arch = .aarch64, .cpu_model = .baseline },

    .{ .os_tag = .macos, .cpu_arch = .aarch64, .cpu_model = .baseline },
};

fn createModule(build: *std.Build, root_src: []const u8, target: std.Target.Query, optimize: ?std.builtin.OptimizeMode) !*std.Build.Module {
    const module = build.createModule(.{
        .root_source_file = build.path(root_src),
        .target = build.resolveTargetQuery(target),
        .optimize = optimize,
        .strip = optimize == .ReleaseFast or optimize == .ReleaseSmall,
    });
    // try appendCSources(build, module, src_dir);
    return module;
}

fn adjustCompileOptions(compile: *std.Build.Step.Compile) void {
    compile.use_llvm = true;
    compile.link_function_sections = true;
    compile.link_data_sections = true;
    compile.link_gc_sections = true;
    compile.is_linking_libc = true;
    compile.stack_size = 16 << 20;
}

pub fn addBin(build: *std.Build, project_name: []const u8, root_src: []const u8, targets: []const std.Target.Query, optimize: ?std.builtin.OptimizeMode) !void {
    for (targets) |target| {
        const module = try createModule(build, root_src, target, optimize);

        const compile = build.addExecutable(.{ .name = project_name, .root_module = module });
        adjustCompileOptions(compile);

        const subpath = build.fmt("{s}-{s}", .{
            @tagName(target.os_tag.?),
            if (target.cpu_model == .explicit) target.cpu_model.explicit.name else @tagName(target.cpu_arch.?),
        });
        const artifact = build.addInstallArtifact(compile, .{ .dest_dir = .{ .override = .{ .custom = subpath } } });
        build.getInstallStep().dependOn(&artifact.step);
    }
}

// pub var c_src_extensions = [_][]const u8{
//     ".c",
//     ".cpp",
//     ".cxx",
//     ".cc",
// };

// fn appendCSources(build: *std.Build, module: *std.Build.Module, src_dir: []const u8) !void {
//     var t = std.Io.Threaded.init_single_threaded;
//     defer t.deinit();
//     const io = t.io();
//     var c_src_dir = try std.Io.Dir.cwd().openDir(io, src_dir, .{ .iterate = true });
//     defer c_src_dir.close(io);
//     var c_src_walker = try c_src_dir.walk(build.allocator);
//     defer c_src_walker.deinit();

//     while (try c_src_walker.next(io)) |entry| {
//         if (entry.kind == .file) {
//             for (c_src_extensions) |c_src_extension| {
//                 if (std.mem.endsWith(u8, entry.basename, c_src_extension)) {
//                     const c_src = build.pathJoin(&.{ src_dir, entry.path });
//                     module.addCSourceFile(.{ .file = build.path(c_src) });
//                     module.link_libc = true;
//                     // std.log.debug("{s:<10} {s:<20} addCSourceFile: {s}", .{ project_name, bin_target_subpath, c_src });
//                 }
//             }
//         }
//     }
// }
