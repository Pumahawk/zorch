const std = @import("std");
const os = @import("os");
const cmd = @import("cmd.zig");

const print = std.debug.print;

const commands = [_]cmd.Cmd{
    @import("commands/Serve.zig").cmd(),
};

pub fn main() !void {
    var args = std.process.args();

    _ = args.next();

    if (args.next()) |subcommand_name| {
        inline for (commands) |command| {
            if (isCommand(subcommand_name, command)) {
                command.cmd(args);
                return;
            }
        } else printCommandNotFound(subcommand_name);

    }
}

fn isCommand(name: [] const u8, command: cmd.Cmd) bool {
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
