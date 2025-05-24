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
    port: u16,

    fn init(allocator: std.mem.Allocator, args: []const []const u8) !Self {
        var flags = Flags.init(allocator);
        const address = try flags.arg("--ip", "127.0.0.1");
        const port = try flags.arg("--port", "9090");
        try flags.parse(args);
        return .{
            .allocator = allocator,
            .address = address.*,
            .port = try std.fmt.parseInt(u16, port.*, 10),
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
    print("Address: {s}, Port: {d}\n", .{flags.address, flags.port});
    print("Start server.\n", .{});

    const address = std.net.Address.parseIp(flags.address, flags.port) catch {
                print("ERROR - Unable to read address {s}\n", .{flags.address});
                return;
    };

    var server = address.listen(.{}) catch {
        print("ERROR - Unable to listen.\n", .{});
        return;
    };
    defer server.deinit();
    const conn = server.accept() catch {
        print("ERROR - Unable to accept requests.\n", .{});
        return;
    };

    var buffHttp: [1080*1080] u8 = undefined;
    var httpServer = std.http.Server.init(conn, &buffHttp);
    var head = httpServer.receiveHead() catch {
        print("ERROR - Unable to get header\n", .{});
        return;
    };

    head.respond("Hello, Wolrd!\n", .{.status = std.http.Status.ok}) catch {
        print("ERROR - Unable to send response\n", .{});
        return;
    };
}
