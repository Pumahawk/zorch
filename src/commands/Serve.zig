const std = @import("std");
const Flags = @import("../Flags.zig");
const ArgIterator = std.process.ArgIterator;
const Serve = @This();
const cmd_p = @import("../cmd.zig");
const Cmd = cmd_p.Cmd;

const print = std.debug.print;

const Conf = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    address: []const u8,

    fn init(allocator: std.mem.Allocator, args: []const []const u8) !Self {
        var flags = Flags.init(allocator);
        const address_opt = try flags.arg("--address");
        try flags.parse(args);
        return .{
            .allocator = allocator,
            .address = if (address_opt.*) |address| address else try allocator.dupe(u8, "localhost:9000"),
        };
    }

    fn deinit(self: *Self) void {
        self.allocator.free(self.address);
    }
};

pub fn cmd() Cmd {
    return .{
        .name = "serve",
        .aliases = &[_][]const u8{"sv"},
        .cmd = serve,
    };
}

pub fn serve(allocator: std.mem.Allocator, args: []const []const u8) void {
    const flags = Conf.init(allocator, args) catch {
        print("ERROR - Unable to read flags.\n", .{});
        return;
    };
    print("Address: {s}\n", .{flags.address});
    print("Start server.\n", .{});
}
