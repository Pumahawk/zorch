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

    pub fn log(self: Self, comptime fmt: []const u8, args: anytype) void {
        self.out.writer().print(fmt, args) catch {
            // Ignore error
        };
    }
};

