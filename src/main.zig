const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));
const menu = @import("menu.zig");
const game = @import("game.zig");
const end = @import("end.zig");
const List = @import("list.zig").List;
const misc = @import("misc.zig");
const Model = misc.Model;
const State = misc.State;
const Action = misc.Action;

const background = rl.Color{ .r = 0xc6, .g = 0xd0, .b = 0x02, .a = 0xff };
const foreground = rl.Color{ .r = 0x6a, .g = 0x57, .b = 0x01, .a = 0xff };

const FPS = 60;
const TPS = 12;

fn reset(bufferAllocator: *std.heap.FixedBufferAllocator) !void {
    bufferAllocator.reset();
    const allocator = bufferAllocator.allocator();
    try menu.reset(allocator);
    try game.reset(allocator);
    try end.reset(allocator);
}

fn update(model: Model) !Model {
    return model.handle(try switch (model.state) {
        .menu => menu.update(model),
        .game => game.update(model),
        .end => end.update(model),
    });
}

fn draw(model: Model) void {
    switch (model.state) {
        .menu => menu.draw(),
        .game => game.draw(),
        .end => end.draw(),
    }
}

fn nextKey() ?i32 {
    const key = rl.GetKeyPressed();
    return if (key != 0) key else null;
}

pub fn main() !void {
    rl.InitWindow(512, 512, "SNAKE");
    defer rl.CloseWindow();

    rl.SetTargetFPS(FPS);

    var buffer: [@sizeOf(List(game.Square).Node) * 16 * 16]u8 = undefined;
    var bufferAllocator = std.heap.FixedBufferAllocator.init(&buffer);

    var model = Model{
        .state = .menu,
        .key = 0,
        .updateFlag = false,
        .resetFlag = true,
    };

    var tick: u32 = 0;
    while (!rl.WindowShouldClose()) : (tick += 1) {
        if (model.resetFlag) {
            try reset(&bufferAllocator);
            model.resetFlag = false;
        }

        var key: i32 = 0;
        while (nextKey()) |next| key = next;
        model = model.handle(Action{ .key = key });

        if (tick == FPS / TPS - 1) {
            model = model.handle(.update);
            tick = 0;
        }

        model = try update(model);
        model.updateFlag = false;

        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(background);
        draw(model);
    }
}
