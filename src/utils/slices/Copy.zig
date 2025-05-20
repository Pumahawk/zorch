const std = @import("std");
const Allocator = std.mem.Allocator;

const types = @import("../types.zig");
const Text = types.Text;

const Copy = @This();

pub fn copy(T: type, s: []const T, a: Allocator) ![]T {
    return try a.dupe(T, s);
}

pub fn deepCopy(T: type, s: []const []const T, a: Allocator) ![][]T {
    var slice = try a.alloc([]T, s.len);
    for (s, 0..) |v, i| {
        slice[i] = try copy(T, v, a);
    }
    return slice;
}

pub fn deinit(T: type, s: []const T, a: Allocator) void {
    a.free(s);
}

pub fn deepDeinit(T: type, s: []const []const T, a: Allocator) void {
    for (s) |v| {
        a.free(v);
    }
    a.free(s);
}

test "copy slice" {
    const cp = try copy(u8, "Hello, Wordl", std.testing.allocator);
    defer deinit(u8, cp, std.testing.allocator);
    try std.testing.expectEqualStrings(cp, "Hello, Wordl");
}

test "copy deep slice" {
    const in = &[_][]const u8{
        "Hello 1",
        "Hello 2",
        "Hello 3",
    };
    const cp = try deepCopy(u8, in, std.testing.allocator);
    defer deepDeinit(u8, cp, std.testing.allocator);
    for (cp, 0..) |text, i| {
        try std.testing.expectEqualStrings(text, in[i]);
    }
}
