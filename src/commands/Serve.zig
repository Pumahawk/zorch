const std = @import("std");
const Thread = std.Thread;
const Flags = @import("../Flags.zig");
const ArgIterator = std.process.ArgIterator;
const Serve = @This();
const cmd_p = @import("../cmd.zig");
const Cmd = cmd_p.Cmd;

const Process = @import("../process/Process.zig");
const logutil = @import("../utils/log.zig");
const log = logutil.Logger.init("Serve");

const controllers = @import("../server/controllers/controller.zig");
const HelloWorldController = controllers.HelloWorldController;

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
        log.info("ERROR - Unable to read flags.", .{});
        return;
    };
    log.info("Address: {s}, Port: {d}", .{flags.address, flags.port});
    log.info("Start server.", .{});

    const address = std.net.Address.parseIp(flags.address, flags.port) catch {
                log.info("ERROR - Unable to read address {s}", .{flags.address});
                return;
    };

    var server = address.listen(.{}) catch {
        log.info("ERROR - Unable to listen.", .{});
        return;
    };
    defer server.deinit();
    req: while (true) {
        const conn = server.accept() catch {
            log.info("ERROR - Unable to accept requests.", .{});
            return;
        };

        var buffHttp: [1080*5] u8 = undefined;
        var httpServer = std.http.Server.init(conn, &buffHttp);
        var head = httpServer.receiveHead() catch {
            log.info("ERROR - Unable to get header", .{});
            break :req;
        };

        log.info("INFO - Incoming request - Target: {s}", .{head.head.target});
        HelloWorldController.controller().handler(.{}, &head);
    }
}
