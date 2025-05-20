const std = @import("std");
const Allocator = std.mem.Allocator;
const Copy = @import("../utils/slices/Copy.zig");
const types = @import("../utils/types.zig");
const Text = types.Text;

const ProcessMeta = struct {
    const Self = @This();

    allocator: Allocator,

    name: Text,
    workdir: Text,
    exec: []const Text,
    env: []const Text,
    tags: []const Text,

    pub fn init(processMeta: ProcessMeta, allocator: Allocator) ProcessMeta {
        return .{
            .allocator = allocator,
            .name = try Copy.copy(Text, processMeta.name, allocator),
            .workdir = try Copy.copy(Text, processMeta.workdir, allocator),
            .exec = try Copy.deepCopy(Text, processMeta.exec, allocator),
            .env = try Copy.deepCopy(Text, processMeta.env, allocator),
            .tags = try Copy.deepCopy(Text, processMeta.tags, allocator),
        };
    }

    // TODO continue...
    pub fn deinit(self: Self) void {}
};

test "init and deinit" {
    // TODO continue...
    var process = ProcessMeta.init(.{
        .name = "",
        .workdir = "",
        .exec = [_]Text{""},
        .env = [_]Text{""},
        .tags = [_]Text{""},
    }, std.mem.Allocator);
}
