const std = @import("std");
const File = std.fs.File;

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
        const fmtc = "INFO " ++ fmt;
        self.out.writer().print(fmtc, args) catch {
            // Ignore error
        };
    }
};

