const std = @import("std");
const c = @cImport({
    @cInclude("time.h");
});
const File = std.fs.File;

const cast = @import("cast.zig");
const slices = @import("slices.zig");

const DateBuff = [20]u8;

const Level = enum {
    INFO,
    ERROR,
    WARN,

    const Self = @This();
    pub fn label(comptime self: Self) [] const u8 {
        return switch (self) {
            .INFO => "INFO",
            .ERROR => "ERROR",
            .WARN => "WARN",
        };
    }
};

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
        self.log(Level.INFO, fmt, args);
    }

    pub fn err(self: Self, comptime fmt: []const u8, args: anytype) void {
        self.log(Level.ERROR, fmt, args);
    }


    fn log(self: Self, comptime level: Level, comptime fmt: []const u8, args: anytype) void {
        var buf: DateBuff = undefined;
        const prefix_fmt = "[{s[date]}] [{s[level]}] ";
        const fmtc = fmt ++ "\n";
        const not_time = now(&buf);
        const log_level = level.label();
        self.print(prefix_fmt, .{
            .date = not_time,
            .level = log_level,
        });
        self.print(fmtc, args);
    }

    fn print(self: Self, comptime fmt: []const u8, args: anytype) void {
        self.out.writer().print(fmt, args) catch {
            // Ignore error
        };
    }
};

fn now(buf: *DateBuff) [] const u8 {
    const time = c.time(null);
    const gmt = c.gmtime(&time);
    if (gmt != null) {
        return std.fmt.bufPrint(buf, "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}Z", .{
            cast.cIntToU32(1900 + gmt.*.tm_year),
            cast.cIntToU32(gmt.*.tm_mon + 1),
            cast.cIntToU32(gmt.*.tm_mday),
            cast.cIntToU32(gmt.*.tm_hour),
            cast.cIntToU32(gmt.*.tm_min),
            cast.cIntToU32(gmt.*.tm_sec),
        }) catch unreachable;
    } else {
        return slices.fill(buf, "undefined");
    }
}


