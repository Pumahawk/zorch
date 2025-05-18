const max_args = 100;
const std = @import("std");
const os = @import("os");
const cmd = @import("cmd.zig");

const print = std.debug.print;

const commands = [_]cmd.Cmd{
    @import("commands/Serve.zig").cmd(),
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var argsSupplier = std.process.args();
    _ = argsSupplier.next();
    var args = try Args.init(allocator, &argsSupplier);
    defer args.deinit();

    if (args.args.len > 0) {
        const subcommand_name = args.args[0];
        inline for (commands) |command| {
            if (isCommand(subcommand_name, command)) {
                command.cmd(allocator, args.args[1..]);
                return;
            }
        } else printCommandNotFound(subcommand_name);
    }
}

fn isCommand(name: []const u8, command: cmd.Cmd) bool {
    if (std.mem.eql(u8, name, command.name)) {
        return true;
    } else {
        for (command.aliases) |alias| {
            if (std.mem.eql(u8, name, alias)) {
                return true;
            }
        }
        return false;
    }
}

fn printCommandNotFound(name: []const u8) void {
    print("Command not found. {s}\n", .{name});
}

const Args = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    i: usize,
    args: [max_args][]const u8,

    fn init(allocator: std.mem.Allocator, argIterator: *std.process.ArgIterator) !Self {
        var args = Self{
            .i = 0,
            .allocator = allocator,
            .args = undefined,
        };
        while (argIterator.next()) |arg| {
            try args.add(arg);
        }
        return args;
    }
    fn add(self: *Self, arg: []const u8) !void {
        if (self.i < self.args.len) {
            self.args[self.i] = try self.allocator.dupe(u8, arg);
            self.i += 1;
        }
    }
    fn deinit(self: *Self) void {
        for (self.args) |arg| {
            self.allocator.free(arg);
        }
    }
};
