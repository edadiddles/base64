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
    
    pub fn encode(self: Base64, str: []const u8) []u8 {
        _ = self;

        for (str) |c| {
            std.debug.print("{b} ", .{c});
        }

        std.debug.print("\n", .{});
        for (str) |c| {
            const bit_transform: u8 = c >> 2;
            std.debug.print("{b} ", .{bit_transform});
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
    _ = b64.encode("Hi");
}

test "encode Hello World" {
    //const b64 = Base64.init();
    //_ = b64.encode("Hello World");
}
