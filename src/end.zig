const rl = @cImport(@cInclude("raylib.h"));
const std = @import("std");
const State = @import("misc.zig").State;
const Model = @import("misc.zig").Model;
const Action = @import("misc.zig").Action;

const FOREGROUND = rl.Color{ .r = 0x6a, .g = 0x57, .b = 0x01, .a = 0xff };

pub fn reset(_: std.mem.Allocator) !void {}

pub fn update(model: Model) !Action {
    if (model.key != 0) return .next;
    return .none;
}

pub fn draw() void {
    rl.DrawText("YOU LOSE", 16, 128, 96, FOREGROUND);
}
