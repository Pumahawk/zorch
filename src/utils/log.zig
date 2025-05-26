const std = @import("std");
const c = @cImport({
    @cInclude("time.h");
});
const File = std.fs.File;

const slices = @import("slices.zig");

pub const Logger = struct {
    const Self = @This();

    name: [] const u8,
    out: File,

    pub fn init(comptime name: [] const u8) Logger {
        return .{
            .name = name,
            .out = std.io.getStdOut(),
        };
    }

    pub fn info(self: Self, comptime fmt: []const u8, args: anytype) void {
        var buf: [25]u8 = undefined;
        const fmtc = " - INFO " ++ fmt ++ "\n";
        const not_time = now(&buf);
        self.print("{s}", .{not_time});
        self.print(fmtc, args);
    }

    fn print(self: Self, comptime fmt: []const u8, args: anytype) void {
        self.out.writer().print(fmt, args) catch {
            // Ignore error
        };
    }
};

//TODO fix output "+2025-+5-+26T+23:+46:+11Z"
fn now(buf: *[25]u8) [] const u8 {
    const time = c.time(null);
    const gmt = c.gmtime(&time);
    if (gmt != null) {
        return std.fmt.bufPrint(buf, "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}Z", .{
            1900 + gmt.*.tm_year,
            gmt.*.tm_mon + 1,
            gmt.*.tm_mday,
            gmt.*.tm_hour,
            gmt.*.tm_min,
            gmt.*.tm_sec,
        }) catch unreachable;
    } else {
        return slices.fill(buf, "undefined");
    }
}


