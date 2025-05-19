const std = @import("std");
const StdIo = Child.StdIo;
const Child = std.process.Child;
const File = std.fs.File;

const Process = @This();

allocator: std.mem.Allocator,
name: []const u8,
exargs: []const []const u8,

pub fn init(allocator: std.mem.Allocator, name: []const u8, exargs: []const []const u8) Process {
    return .{
        .allocator = allocator,
        .name = name,
        .exargs = exargs,
    };
}

pub fn deinit(self: *Process) void {
    _ = self;
}

pub fn run(self: Process, allocator: std.mem.Allocator) !void {
    var child = Child.init(self.exargs, allocator);
    child.stdout = std.io.getStdOut();
    _ = try child.spawnAndWait();
}
