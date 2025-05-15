const std = @import("std");
const ArgIterator = std.process.ArgIterator;
const Serve = @This();
const cmd_p = @import("../cmd.zig");
const Cmd = cmd_p.Cmd;

const print = std.debug.print;

pub fn cmd() Cmd {
    return .{
    .name = "serve",
    .aliases = &[_][]const u8{"sv"},
    .cmd = serve,
    };
}

pub fn serve(_: ArgIterator) void {
    print("Start server.\n", .{});
}
