const std = @import("std");
const max_args: usize = 100;

const Option = struct {
    key: []const u8,
    value: []const u8,
};

const Flags = @This();

allocator: std.mem.Allocator,
i: usize,
options: [max_args]Option,

pub fn init(allocator: std.mem.Allocator) Flags {
    return .{
        .i = 0,
        .options = undefined,
        .allocator = allocator,
    };
}

pub fn arg(self: *Flags, n: []const u8, def: []const u8) !*[]const u8 {
    return if (self.i < self.options.len) {
        self.options[self.i] = Option{
            .key = try self.allocator.dupe(u8, n),
            .value = try self.allocator.dupe(u8, def),
        };
        self.i += 1;
        return &self.options[self.i - 1].value;
    } else error.BuffLen;
}

pub fn parse(self: *Flags, args: []const []const u8) !void {
    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        for (&self.options) |*opt| {
            if (std.mem.eql(u8, opt.key, args[i])) {
                if (i + 1 < args.len) {
                    i += 1;
                    const adr = args[i];
                    self.allocator.free(opt.value);
                    opt.value = try self.allocator.dupe(u8, adr);
                }
            }
        }
    }
}

pub fn deinit(self: Flags) void {
    var i: usize = 0;
    while (i < self.i) : (i += 1) {
        self.allocator.free(self.options[i].key);
    }
}
