const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));
const Model = @import("misc.zig").Model;
const Action = @import("misc.zig").Action;
const State = @import("misc.zig").State;

const FOREGROUND = rl.Color{ .r = 0x6a, .g = 0x57, .b = 0x01, .a = 0xff };

pub fn reset(_: std.mem.Allocator) !void {}

pub fn update(model: Model) !Action {
    if (model.key != 0) return .next;
    return .none;
}

pub fn draw() void {
    rl.DrawText("SNAKE", 96, 128, 96, FOREGROUND);
}
