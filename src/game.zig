const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));
const List = @import("list.zig").List;
const State = @import("misc.zig").State;
const Model = @import("misc.zig").Model;
const Action = @import("misc.zig").Action;

const FOREGROUND = rl.Color{ .r = 0x6a, .g = 0x57, .b = 0x01, .a = 0xff };

const Direction = enum { left, right, up, down };

pub const Square = struct {
    const s = 32;
    x: i32,
    y: i32,
    fn random() Square {
        return Square{ .x = rand.uintLessThanBiased(u8, 16), .y = rand.uintLessThanBiased(u8, 16) };
    }
    fn draw(square: *const Square) void {
        rl.DrawRectangle(square.x * s, square.y * s, s - 2, s - 2, FOREGROUND);
    }
};

var prng: std.rand.DefaultPrng = undefined;
var rand: std.rand.Random = undefined;
var food: Square = undefined;
var direction: Direction = undefined;
var snake: List(Square) = undefined;

pub fn reset(allocator: std.mem.Allocator) !void {
    prng = std.rand.DefaultPrng.init(@bitCast(u64, std.time.timestamp()));
    rand = prng.random();
    food = Square.random();
    direction = .up;
    snake = List(Square).init(allocator);
    try snake.create(Square{ .x = 8, .y = 8 });
    try snake.create(Square{ .x = 8, .y = 8 });
    try snake.create(Square{ .x = 8, .y = 8 });
}

fn extend(next: Square) !void {
    try snake.create(next);
    food = Square.random();
}

fn move(next: Square) void {
    var moved = snake.pop().?;
    moved.value = next;
    snake.push(moved);
}

fn outOfBounds(next: Square) bool {
    return next.x < 0 or next.x > 15 or next.y < 0 or next.y > 15;
}

fn getNext() Square {
    var next = snake.head.?.value;
    switch (direction) {
        .left => next.x -= 1,
        .right => next.x += 1,
        .up => next.y -= 1,
        .down => next.y += 1,
    }
    return next;
}

fn getDirection(key: i32) Direction {
    return switch (key) {
        65 => .left,
        68 => .right,
        87 => .up,
        83 => .down,
        else => direction,
    };
}

pub fn update(model: Model) !Action {
    direction = getDirection(model.key);
    if (model.updateFlag) {
        const next = getNext();
        if (outOfBounds(next) or snake.includes(next)) return .next;
        if (std.meta.eql(snake.head.?.value, food)) try extend(next) else move(next);
    }
    return .none;
}

pub fn draw() void {
    food.draw();
    var iter = snake.iterator();
    while (iter.next()) |square| {
        square.draw();
    }
}
