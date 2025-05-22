const std = @import("std");
const Allocator = std.mem.Allocator;
const Copy = @import("../utils/slices/Copy.zig");
const types = @import("../utils/types.zig");
const Text = types.Text;

const ProcessMeta = struct {
    const Self = @This();

    allocator: Allocator = undefined,

    name: Text,
    workdir: Text,
    exec: []const Text,
    env: []const Text,
    tags: []const Text,

    pub fn init(processMeta: ProcessMeta, allocator: Allocator) !ProcessMeta {
        return .{
            .allocator = allocator,
            .name = try Copy.copy(u8, processMeta.name, allocator),
            .workdir = try Copy.copy(u8, processMeta.workdir, allocator),
            .exec = try Copy.deepCopy(u8, processMeta.exec, allocator),
            .env = try Copy.deepCopy(u8, processMeta.env, allocator),
            .tags = try Copy.deepCopy(u8, processMeta.tags, allocator),
        };
    }

    pub fn deinit(self: Self) void {
        Copy.deinit(u8, self.name, self.allocator);
        Copy.deinit(u8, self.workdir, self.allocator);
        Copy.deepDeinit(u8, self.exec, self.allocator);
        Copy.deepDeinit(u8, self.env, self.allocator);
        Copy.deepDeinit(u8, self.tags, self.allocator);
    }
};

test "init and deinit" {
    var process = try ProcessMeta.init(.{
        .name = "name-process",
        .workdir = "workdir-process",
        .exec = &[_]Text{"exec-process"},
        .env = &[_]Text{"env-process"},
        .tags = &[_]Text{"tags-process"},
    }, std.testing.allocator);
    defer process.deinit();

    try std.testing.expectEqualStrings("name-process", process.name);
    try std.testing.expectEqualStrings("workdir-process", process.workdir);
    try std.testing.expectEqualStrings("exec-process", process.exec[0]);
    try std.testing.expectEqual(1, process.exec.len);
    try std.testing.expectEqualStrings("env-process", process.env[0]);
    try std.testing.expectEqual(1, process.env.len);
    try std.testing.expectEqualStrings("tags-process", process.tags[0]);
    try std.testing.expectEqual(1, process.tags.len);
}
