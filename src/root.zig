//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

const Base64 = struct{
    lkup_tbl: *const [64]u8,

    pub fn init() Base64 {
        return Base64{
            .lkup_tbl = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",
        };
    }

    pub fn get_char(self: Base64, idx: usize) u8 {
        return self.lkup_tbl[idx];
    }
    
    pub fn encode(self: Base64, str: []const u8) ![]u8 {
        
        const allocator = std.testing.allocator;
        const buffer = try allocator.alloc(u8, 1024);
        defer allocator.free(buffer);

        for (str) |c| {
            std.debug.print("{c}", .{c});
        }

        std.debug.print("\n", .{});
        var window_buf = [3]u8{0, 0, 0};
        var window_buf_idx: u8 = 0;
        var buffer_idx: u8 = 0;
        for (str) |c| {
            window_buf[window_buf_idx] = c;
            window_buf_idx += 1;
            
            if (window_buf_idx == 3) {
                buffer[buffer_idx] = self.lkup_tbl[window_buf[0] >> 2];
                buffer[buffer_idx+1] = self.lkup_tbl[((window_buf[0] & 0x03) << 4) + (window_buf[1] >> 4)];
                buffer[buffer_idx+2] = self.lkup_tbl[((window_buf[1] & 0x0f) << 2) + (window_buf[2] >> 6)];
                buffer[buffer_idx+3] = self.lkup_tbl[window_buf[2] & 0x0f];
                window_buf_idx = 0;
                buffer_idx += 4;
            }
        }

        if (window_buf_idx == 1) {
            buffer[buffer_idx] = self.lkup_tbl[window_buf[0] >> 2];
            buffer[buffer_idx+1] = self.lkup_tbl[((window_buf[0] & 0x03) << 4)];
            buffer[buffer_idx+2] = '=';
            buffer[buffer_idx+3] = '=';
            buffer_idx += 4;
        }

        if (window_buf_idx == 2) {
            buffer[buffer_idx] = self.lkup_tbl[window_buf[0] >> 2];
            buffer[buffer_idx+1] = self.lkup_tbl[((window_buf[0] & 0x03) << 4) + (window_buf[1] >> 4)];
            buffer[buffer_idx+2] = self.lkup_tbl[((window_buf[1] & 0x0f) << 2)];
            buffer[buffer_idx+3] = '=';
            buffer_idx += 4;
        }

        for (buffer) |b| {
            std.debug.print("{c}", .{b});
        }
        std.debug.print("\n", .{});
        return &[0]u8{};
    }

    pub fn decode(self: Base64, str: []u8) []u8 {
        _ = self;
        _ = str;
        return &[0]u8{};
    }
    
};


test "encode Hi" {
    const b64 = Base64.init();
    _ = try b64.encode("Hi");
}

test "encode Hello World" {
    const b64 = Base64.init();
    _ = try b64.encode("Hello World");
}

test "encode foobar" {
    const b64 = Base64.init();
    _ = try b64.encode("");
    _ = try b64.encode("f");
    _ = try b64.encode("fo");
    _ = try b64.encode("foo");
    _ = try b64.encode("foob");
    _ = try b64.encode("fooba");
    _ = try b64.encode("foobar");
}
