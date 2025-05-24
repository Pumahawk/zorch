const std = @import("std");
const RequestHttp = std.http.Server.Request;

const print = std.debug.print;

pub const Handler = fn (Context, *RequestHttp) void;

pub const Controller = struct {
    path: [] const u8,
    handler: Handler,
};

pub const Context = struct {
};

pub const HelloWorldController = struct {
    const Self = @This();

    pub fn controller() Controller {
        return .{
            .path = "/hello",
            .handler = Self.handle,
        };
    }

    fn handle(_: Context, request: *RequestHttp) void {
        request.respond("Hello, World!\n", .{.status = std.http.Status.ok}) catch {
            print("ERROR - Unable to send response\n", .{});
            return;
        };
    }
};
