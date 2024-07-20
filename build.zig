const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "downside",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.addIncludePath(b.path("lib/SDL/include"));
    exe.addLibraryPath(b.path("lib/SDL/build/Release"));
    exe.linkSystemLibrary("SDL3");

    exe.addIncludePath(b.path("lib/glew-2.1.0/include"));
    exe.addLibraryPath(b.path("lib/glew-2.1.0/lib/Release/x64"));
    exe.linkSystemLibrary("glew32");

    exe.linkSystemLibrary("OpenGL32");

    exe.linkLibC();

    // zlib
    const zlib = b.addStaticLibrary(.{
        .name = "zlib",
        .target = target,
        .optimize = optimize,
    });

    var zlib_config = std.Build.Step.ConfigHeader.create(b, .{ .style = .{ .autoconf = b.path("lib/zlib-1.2.12/zconf.h.in") } });
    zlib_config.addValues(.{ .z_longlong = null, .FAR = null, ._LARGEFILE64_SOURCE = null });
    zlib.addConfigHeader(zlib_config);
    zlib.installHeadersDirectory(b.path("lib/zlib-1.2.12"), "", .{});
    zlib.installConfigHeader(zlib_config);

    zlib.linkLibC();

    zlib.addCSourceFiles(.{ .root = b.path("lib/zlib-1.2.12"), .files = &.{
        "adler32.c",
        "compress.c",
        "crc32.c",
        "deflate.c",
        "gzclose.c",
        "gzlib.c",
        "gzread.c",
        "gzwrite.c",
        "inflate.c",
        "infback.c",
        "inftrees.c",
        "inffast.c",
        "trees.c",
        "uncompr.c",
        "zutil.c",
    } });

    //lib png
    const cwd = std.fs.cwd();
    try std.fs.Dir.copyFile(
        cwd,
        "lib/lpng1637/scripts/pnglibconf.h.prebuilt",
        cwd,
        "lib/lpng1637/pnglibconf.h",
        .{},
    );
    const lib_png = b.addStaticLibrary(.{
        .name = "libpng",
        .target = target,
        .optimize = optimize,
    });
    zlib.installHeadersDirectory(b.path("lib/lpng1637/"), "", .{});
    lib_png.addCSourceFiles(.{
        .root = b.path("lib/lpng1637"),
        .files = &.{
            "png.c",
            "pngerror.c",
            "pngget.c",
            "pngmem.c",
            "pngpread.c",
            "pngread.c",
            "pngrio.c",
            "pngrtran.c",
            "pngrutil.c",
            "pngset.c",
            "pngtrans.c",
            "pngwio.c",
            "pngwrite.c",
            "pngwtran.c",
            "pngwutil.c",
        },
    });
    lib_png.linkLibrary(zlib);
    lib_png.linkLibC();

    exe.linkLibrary(lib_png);

    exe.linkLibrary(zlib);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    b.installFile("lib/SDL/build/Release/SDL3.dll", "bin/SDL3.dll");
    b.installFile("lib/glew-2.1.0/bin/Release/x64/glew32.dll", "bin/glew32.dll");

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
