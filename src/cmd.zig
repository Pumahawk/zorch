const std = @import("std");
const ArgIterator = std.process.ArgIterator;

pub const Cmd = struct {
    name: []const u8,
    aliases: []const []const u8,
    cmd: CmdFn,
};

pub const CmdFn = fn (std.mem.Allocator, *ArgIterator) void;
