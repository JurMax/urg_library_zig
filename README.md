
# urg_library_zig

This is a port of the [URG library](https://github.com/UrgNetwork/urg_library) to the [Zig](https://ziglang.org/) build system.

## How to use it

Run any of the samples:

```bash
zig build get_distance
zig build get_distance_handshake
zig build get_distance_intensity
zig build get_multiecho
zig build get_multiecho_intensity
zig build sync_time_stamp
zig build sensor_parameter
zig build calculate_xy
zig build find_port
zig build timeout_test
zig build reboot_test
zig build angle_convert_test
```

Or any of the C++ samples:

```bash
zig build -Dcpp get_distance
zig build -Dcpp get_distance_handshake
zig build -Dcpp get_distance_intensity
zig build -Dcpp get_multiecho
zig build -Dcpp get_multiecho_intensity
zig build -Dcpp sync_time_stamp
zig build -Dcpp sensor_parameter
```

### As a library

First, fetch this repository:

```bash
zig fetch --save git+https://github.com/JurMax/urg_library_zig
```

Next, add it to your `build.zig`:

```zig
const urg_library = b.dependency("urg_library_zig", .{
    .target = target,
    .optimize = optimize,
});
exe.linkLibrary(urg_library);
```

This will add the URG library and headers to `exe`.
