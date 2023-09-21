const std = @import("std");

const Mark = enum { E, X, O };

const Board = struct {
    tiles: [9]Mark,

    pub fn setTile(self: *Board, tileIdx: usize, mark: Mark) void {
        self.tiles[tileIdx] = mark;
    }

    pub fn print(self: Board) void {
        var cnt: i32 = 0;
        for (self.tiles) |mark| {
            if (@mod(cnt, 3) == 0 and cnt != 0) {
                std.debug.print("\n", .{});
            }
            switch (mark) {
                Mark.E => std.debug.print(". ", .{}),
                Mark.X => std.debug.print("X ", .{}),
                Mark.O => std.debug.print("O ", .{}),
            }
            if (cnt == 8) {
                std.debug.print("\n", .{});
            }
            cnt += 1;
        }
    }
};

const Player = enum { X, O };

const Game = struct {
    board: Board,
    playerIsX: bool,

    pub fn move(self: *Game, tileIdx: usize) void {
        if (self.playerIsX) {
            self.board.setTile(tileIdx, Mark.X);
        } else {
            self.board.setTile(tileIdx, Mark.O);
        }
        self.swapPlayer();
    }

    fn swapPlayer(self: *Game) void {
        self.playerIsX = !self.playerIsX;
    }

    fn checkWinCondition(self: Game) bool {
        _ = self;
    }
};

fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    var line = (try reader.readUntilDelimiterOrEof(buffer, '\n')) orelse return null;
    // trim annoying windows-only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

pub fn main() !void {
    var board = Board{ .tiles = [9]Mark{
        .E, .E, .E,
        .E, .E, .E,
        .E, .E, .E,
    } };
    board.tiles[0] = Mark.X;
    board.tiles[3] = Mark.X;
    board.setTile(4, Mark.O);
    board.print();

    var running = true;

    const stdin = std.io.getStdIn();

    var buffer: [100]u8 = undefined;
    while (running) {
        std.debug.print("Your move: ", .{});
        const input = (try nextLine(stdin.reader(), &buffer)).?;
        std.debug.print("input: {s}\n", .{input});
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
