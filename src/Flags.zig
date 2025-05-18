const std = @import("std");

const Flags = @This();

allocator: std.mem.Allocator,
i: usize,
keys: [100][] const u8,
values: [100]?[] const u8,

pub fn init(allocator: std.mem.Allocator) Flags {
    return .{
        .i = 0,
        .keys = undefined,
        .values = undefined,
        .allocator = allocator,
    };
}

pub fn arg(self: *Flags, n: []const u8) !*?[] const u8 {
    return if (self.i < self.keys.len) {
        self.keys[self.i] = try self.allocator.dupe(u8, n);
        self.values[self.i] = null;
        const prop = &self.values[self.i];
        self.i += 1;
        return prop;
    } else error.BuffLen;
}

pub fn parse(self: *Flags, args: [] const [] const u8) !void {
    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        for (self.keys, 0..) | key, j | {
            if (std.mem.eql(u8, key, args[i])) {
                var address_opt = self.values[j];
                if (i + 1 < args.len) {
                    i += 1;
                    const adr = args[i];
                    if (address_opt) |address| {
                        self.allocator.free(address);
                    }
                    address_opt = try self.allocator.dupe(u8, adr);
                    self.values[j] = address_opt;
                }
            }
        }
    }
}
