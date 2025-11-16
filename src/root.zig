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
        if (str.len == 0) {
            return "";
        }

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
                buffer[buffer_idx+3] = self.get_char(window_buf[2] & 0x3f);
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
    try std.testing.expectEqualStrings("SGk=", actual);
}

test "encode Hello World" {
    //const b64 = Base64.init();
    //const allocator = std.testing.allocator;
    //const actual = try b64.encode(allocator, "Hello World");
    //allocator.free(actual);
}

test "encode foobar" {
    const b64 = Base64.init();
    const allocator = std.testing.allocator;
    
    const actual0 = try b64.encode(allocator, ""); 
    defer allocator.free(actual0);
    try std.testing.expectEqualStrings("", actual0);
    
    const actual1 = try b64.encode(allocator, "f");
    defer allocator.free(actual1);
    try std.testing.expectEqualStrings("Zg==", actual1);

    const actual2 = try b64.encode(allocator, "fo");
    defer allocator.free(actual2);
    try std.testing.expectEqualStrings("Zm8=", actual2);
    
    const actual3 = try b64.encode(allocator, "foo");
    defer allocator.free(actual3);
    try std.testing.expectEqualStrings("Zm9v", actual3);
   
    const actual4 = try b64.encode(allocator, "foob");
    defer allocator.free(actual4);
    try std.testing.expectEqualStrings("Zm9vYg==", actual4);
    
    const actual5 = try b64.encode(allocator, "fooba");
    defer allocator.free(actual5);
    try std.testing.expectEqualStrings("Zm9vYmE=", actual5);
    
    const actual6 = try b64.encode(allocator, "foobar");
    defer allocator.free(actual6);
    try std.testing.expectEqualStrings("Zm9vYmFy", actual6);
}
