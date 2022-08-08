const std = @import("std");
const net = std.net;

const Message = struct {
    mode: []const u8,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    const runtime_dir = std.os.getenv("XDG_RUNTIME_DIR") orelse {
        std.log.err("XDG_RUNTIME_DIR does not exist, don't know what to do so i'm panicking.", .{});
        return error.NoXDG_RUNTIME_DIR;
    };

    const socket_path = try std.fmt.allocPrintZ(allocator, "{s}/colorchange.socket", .{runtime_dir});
    defer allocator.free(socket_path);
    _ = std.os.linux.unlink(socket_path);

    const address = try net.Address.initUnix(socket_path);
    var socket = net.StreamServer.init(.{});
    defer socket.close();

    try socket.listen(address);

    const stdout = std.io.getStdOut();

    var conn_count: u32 = 0;
    var running = true;
    while (running) {
        const connection = try socket.accept();
        conn_count += 1;

        running = handleMessage(connection, allocator, stdout) catch |e| {
            switch (e) {
                else => |err| {
                    std.log.err("Failed after {} connections: {}", .{ conn_count, err });
                    running = false;
                    return;
                },
            }
        };
    }
}

fn handleMessage(connection: net.StreamServer.Connection, allocator: std.mem.Allocator, stdout: std.fs.File) !bool {
    if (try connection.stream.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1000)) |bytes| {
        if (std.mem.startsWith(u8, bytes, "quit")) {
            return false;
        }

        if (std.mem.eql(u8, bytes, "dark")) {
            try sendMessage(allocator, stdout.writer(), Message {
                .mode = "dark",
            });
        }

        if (std.mem.eql(u8, bytes, "light")) {
            try sendMessage(allocator, stdout.writer(), Message {
                .mode = "light",
            });
        }
    }
    return true;
}

fn sendMessage(allocator: std.mem.Allocator, writer: anytype, message: Message) !void {
    const encoded_message = try std.json.stringifyAlloc(allocator, message, .{});
    defer allocator.free(encoded_message);

    try writer.writeInt(u32, @intCast(u32, encoded_message.len), std.builtin.Endian.Little);
    try writer.writeAll(encoded_message);
}
