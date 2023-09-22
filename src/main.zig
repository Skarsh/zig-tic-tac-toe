const std = @import("std");

const Mark = enum { E, X, O };

const Board = struct {
    const Self = @This();
    tiles: [9]Mark,

    pub fn setTile(self: *Self, tileIdx: usize, mark: Mark) void {
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

const WinCondition = enum { Win, Draw, None };

const Game = struct {
    const Self = @This();
    board: Board,
    playerIsX: bool,

    pub fn move(self: *Self, tileIdx: usize) bool {
        if (self.board.tiles[tileIdx] != Mark.E) {
            return false;
        }
        if (self.playerIsX) {
            self.board.setTile(tileIdx, Mark.X);
        } else {
            self.board.setTile(tileIdx, Mark.O);
        }
        self.swapPlayer();
        return true;
    }

    fn swapPlayer(self: *Game) void {
        self.playerIsX = !self.playerIsX;
    }

    fn checkWinCondition(self: Game) WinCondition {
        const tiles = self.board.tiles;

        if (tiles[0] == tiles[1] and tiles[0] == tiles[2] and tiles[0] != Mark.E) {
            return .Win;
        } else if (tiles[3] == tiles[4] and tiles[3] == tiles[5] and tiles[3] != Mark.E) {
            return .Win;
        } else if (tiles[6] == tiles[7] and tiles[6] == tiles[8] and tiles[6] != Mark.E) {
            return .Win;
        } else if (tiles[0] == tiles[3] and tiles[0] == tiles[6] and tiles[0] != Mark.E) {
            return .Win;
        } else if (tiles[1] == tiles[4] and tiles[1] == tiles[7] and tiles[1] != Mark.E) {
            return .Win;
        } else if (tiles[2] == tiles[5] and tiles[2] == tiles[8] and tiles[2] != Mark.E) {
            return .Win;
        } else if (tiles[0] == tiles[4] and tiles[0] == tiles[8] and tiles[0] != Mark.E) {
            return .Win;
        } else if (tiles[2] == tiles[4] and tiles[2] == tiles[6] and tiles[2] != Mark.E) {
            return .Win;
        }

        // check if all tiles are filled, if they are then its a draw
        var allTilesFilled = true;
        for (0..8) |i| {
            allTilesFilled = allTilesFilled and tiles[i] != Mark.E;
        }

        if (allTilesFilled) {
            return .Draw;
        }

        return .None;
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

fn handleInput(input: []const u8) error{IllegalTileIdx}!usize {
    const tileIdx = std.fmt.parseInt(usize, input, 10) catch {
        return error.IllegalTileIdx;
    };

    if (tileIdx < 0 or tileIdx > 8) {
        // deal with illegal tileIdx
        return error.IllegalTileIdx;
    } else {
        return tileIdx;
    }
}

pub fn main() !void {
    var board = Board{ .tiles = [9]Mark{
        .E, .E, .E,
        .E, .E, .E,
        .E, .E, .E,
    } };

    board.print();

    var game = Game{ .board = board, .playerIsX = true };

    var running = true;

    const stdin = std.io.getStdIn();

    var buffer: [100]u8 = undefined;
    while (running) {
        std.debug.print("Your move: ", .{});
        const input = (try nextLine(stdin.reader(), &buffer)).?;
        const tileIdx = handleInput(input) catch {
            std.debug.print("Illegal input!\n", .{});
            continue;
        };
        const didMove = game.move(tileIdx);
        if (!didMove) {
            std.debug.print("Tile is occupied, try again!\n", .{});
        }
        const winCondition = game.checkWinCondition();
        switch (winCondition) {
            .Win => {
                if (game.playerIsX) {
                    std.debug.print("Player X is the Winner!!!\n", .{});
                } else {
                    std.debug.print("Player X is the Winner!!!\n", .{});
                }
            },
            .Draw => {
                std.debug.print("Its a Draw...\n", .{});
            },
            .None => {},
        }
        game.board.print();
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
