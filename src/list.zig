const std = @import("std");

pub fn List(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            value: T,
            next: ?*Node,
        };

        const Iterator = struct {
            cursor: ?*Node,
            pub fn next(iter: *Iterator) ?T {
                const cursor = iter.cursor orelse return null;
                iter.cursor = cursor.next;
                return cursor.value;
            }
        };

        allocator: std.mem.Allocator,

        head: ?*Node,
        tail: ?*Node,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .head = null,
                .tail = null,
            };
        }

        pub fn deinit(list: *Self) void {
            var cursor = list.tail;
            while (cursor) |node| {
                cursor = node.next;
                list.allocator.destroy(node);
            }
        }

        pub fn iterator(list: *Self) Iterator {
            return Iterator{ .cursor = list.tail };
        }

        pub fn push(list: *Self, node: *Node) void {
            if (list.tail == null) {
                list.tail = node;
            } else {
                list.head.?.next = node;
            }

            list.head = node;
        }

        pub fn pop(list: *Self) ?*Node {
            var tail = list.tail orelse return null;
            list.tail = tail.next;
            tail.next = null;
            return tail;
        }

        pub fn create(list: *Self, value: T) !void {
            var node = try list.allocator.create(Node);
            node.value = value;
            node.next = null;
            list.push(node);
        }

        pub fn remove(list: *Self) ?T {
            const node = list.pop() orelse return null;
            defer list.allocator.destroy(node);
            return node.value;
        }

        pub fn includes(list: *Self, value: T) bool {
            var iter = list.iterator();
            while (iter.next()) |elem| {
                if (std.meta.eql(elem, value)) return true;
            }
            return false;
        }
    };
}

test {
    var list = List(i32).init(std.testing.allocator);
    defer list.deinit();

    try list.create(1);
    try list.create(2);
    try list.create(3);

    try std.testing.expect(list.remove().? == 1);
    try std.testing.expect(list.remove().? == 2);

    try list.create(4);

    try std.testing.expect(list.remove().? == 3);
    try std.testing.expect(list.remove().? == 4);
    try std.testing.expect(list.remove() == null);

    try list.create(5);
    try list.create(6);
    try list.create(7);

    var iter = list.iterator();
    try std.testing.expect(iter.next().? == 5);
    try std.testing.expect(iter.next().? == 6);
    try std.testing.expect(iter.next().? == 7);
    try std.testing.expect(iter.next() == null);

    try std.testing.expect(list.remove().? == 5);
}
