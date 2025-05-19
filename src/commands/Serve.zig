const std = @import("std");
const Thread = std.Thread;
const Flags = @import("../Flags.zig");
const ArgIterator = std.process.ArgIterator;
const Serve = @This();
const cmd_p = @import("../cmd.zig");
const Cmd = cmd_p.Cmd;

const Process = @import("../process/Process.zig");

const print = std.debug.print;

const Conf = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    address: []const u8,

    fn init(allocator: std.mem.Allocator, args: []const []const u8) !Self {
        var flags = Flags.init(allocator);
        const address = try flags.arg("--address", "localshot:9000");
        try flags.parse(args);
        return .{
            .allocator = allocator,
            .address = address.*,
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

    // Testing Process creation and execution
    const cargs = &[_][]const u8{ "echo", "Hello, World" };
    var pr = Process.init(allocator, "echo", cargs);
    defer pr.deinit();
    pr.run(allocator) catch {
        print("ERROR - Unable to execute external process", .{});
        return;
    };
}
