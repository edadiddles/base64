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

    fn encode_length(_: Base64, input_len: usize) usize {
        return ((input_len/4)+1)*4;
    }
    
    pub fn encode(self: Base64, allocator: std.mem.Allocator, str: []const u8) ![]u8 { 
        const buffer = try allocator.alloc(u8, self.encode_length(str.len));

        var window_buf = [3]u8{0, 0, 0};
        var window_buf_idx: u8 = 0;
        var buffer_idx: u8 = 0;
        for (str) |c| {
            window_buf[window_buf_idx] = c;
            window_buf_idx += 1;
            
            if (window_buf_idx == 3) {
                buffer[buffer_idx] = self.get_char(window_buf[0] >> 2);
                buffer[buffer_idx+1] = self.get_char(((window_buf[0] & 0x03) << 4) + (window_buf[1] >> 4));
                buffer[buffer_idx+2] = self.get_char(((window_buf[1] & 0x0f) << 2) + (window_buf[2] >> 6));
                buffer[buffer_idx+3] = self.get_char(window_buf[2] & 0x0f);
                window_buf_idx = 0;
                buffer_idx += 4;
            }
        }

        if (window_buf_idx == 1) {
            buffer[buffer_idx] = self.get_char(window_buf[0] >> 2);
            buffer[buffer_idx+1] = self.get_char(((window_buf[0] & 0x03) << 4));
            buffer[buffer_idx+2] = '=';
            buffer[buffer_idx+3] = '=';
            buffer_idx += 4;
        }

        if (window_buf_idx == 2) {
            buffer[buffer_idx] = self.get_char(window_buf[0] >> 2);
            buffer[buffer_idx+1] = self.get_char(((window_buf[0] & 0x03) << 4) + (window_buf[1] >> 4));
            buffer[buffer_idx+2] = self.get_char(((window_buf[1] & 0x0f) << 2));
            buffer[buffer_idx+3] = '=';
            buffer_idx += 4;
        }

        return buffer;
    }

    pub fn decode(self: Base64, str: []u8) []u8 {
        _ = self;
        _ = str;
        return &[0]u8{};
    }
    
};


test "encode Hi" {
    const b64 = Base64.init();
    const allocator = std.testing.allocator;
    const actual = try b64.encode(allocator, "Hi");
    defer allocator.free(actual);
    std.debug.print("{s}\n", .{ actual });
    try std.testing.expectEqualStrings(actual, "SGk=");
}

test "encode Hello World" {
    //const b64 = Base64.init();
    //const allocator = std.testing.allocator;
    //const actual = try b64.encode(allocator, "Hello World");
    //allocator.free(actual);
}

test "encode foobar" {
    //const b64 = Base64.init();
    //const allocator = std.testing.allocator;
    //_ = try b64.encode(allocator, "");
    //_ = try b64.encode(allocator, "f");
    //_ = try b64.encode(allocator, "fo");
    //_ = try b64.encode(allocator, "foo");
    //_ = try b64.encode(allocator, "foob");
    //_ = try b64.encode(allocator, "fooba");
    //_ = try b64.encode(allocator, "foobar");
    //allocator.free(actual);
}
