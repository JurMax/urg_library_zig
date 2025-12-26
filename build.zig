const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const cpp = b.option(bool, "cpp", "Include C++ code") orelse false;

    const upstream = b.dependency("urg_library", .{});
    const lib = b.addLibrary(.{
        .name = "urg_library",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .link_libcpp = cpp,
        }),
    });

    lib.installHeadersDirectory(upstream.path("current/include/c"), "", .{});
    lib.root_module.addIncludePath(upstream.path("current/include/c"));
    lib.root_module.addCSourceFiles(.{
        .root = upstream.path("current/src"),
        .files = &.{
            "urg_connection.c",
            "urg_debug.c",
            "urg_ring_buffer.c",
            "urg_sensor.c",
            "urg_serial.c",
            "urg_serial_utils.c",
            "urg_tcpclient.c",
            "urg_utils.c",
        },
    });

    if (cpp) {
        lib.installHeadersDirectory(upstream.path("current/include/cpp"), "", .{});
        lib.root_module.addIncludePath(upstream.path("current/include/cpp"));
        lib.root_module.addCSourceFiles(.{
            .root = upstream.path("current/src"),
            .files = &.{
                "Urg_driver.cpp",
                "ticks.cpp",
            },
        });
    }

    // Add run steps for the samples.
    const samples = .{
        "get_distance",
        "get_distance_handshake",
        "get_distance_intensity",
        "get_multiecho",
        "get_multiecho_intensity",
        "sync_time_stamp",
        "sensor_parameter",

        // These only work in C.
        "calculate_xy",
        "find_port",
        "timeout_test",
        "reboot_test",
        "angle_convert_test",
    };
    inline for (samples) |name| {
        const sample = b.addExecutable(.{
            .name = name,
            .root_module = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .link_libc = true,
                .link_libcpp = cpp,
            }),
        });
        sample.root_module.linkLibrary(lib);
        sample.root_module.addIncludePath(upstream.path("current/include/c"));
        sample.root_module.addIncludePath(upstream.path("current/include/cpp"));
        sample.root_module.addCSourceFiles(.{
            .root = upstream.path("current/samples"),
            .files = &.{
                if (cpp) "cpp/" ++ name ++ ".cpp" else "c/" ++ name ++ ".c",
                if (cpp) "cpp/Connection_information.cpp" else "c/open_urg_sensor.c",
            },
        });

        // Add a run step for the sample.
        const run_sample = b.addRunArtifact(sample);
        const run_step = b.step(name, "Run the " ++ name ++ " sample");
        run_step.dependOn(&run_sample.step);
    }
}
