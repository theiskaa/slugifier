const std = @import("std");
const ascii = std.ascii;

/// Slugify a string. This function will convert a string to a slug.
/// It will remove all non-alphanumeric characters and replace them with a separator.
///
/// # Arguments
/// - `input`: The string to slugify.
/// - `allocator`: The allocator to use for the result.
///
/// # Returns
/// - A slugified string.
pub fn slugify(input: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    var lastWasSeperator = false;
    for (input) |c| {
        if (ascii.isAlphanumeric(c)) {
            try buffer.append(std.ascii.toLower(c));
            lastWasSeperator = false;
            continue;
        }

        if (isSeparatorChar(c) and !lastWasSeperator and buffer.items.len > 0) {
            // TODO: use seperator from the options
            try buffer.append('-');
            lastWasSeperator = true;
        }
    }

    if (buffer.items.len > 0 and buffer.items[buffer.items.len - 1] == '-') {
        _ = buffer.pop();
    }

    return buffer.toOwnedSlice();
}

fn isSeparatorChar(c: u8) bool {
    return std.ascii.isWhitespace(c) or switch (c) {
        '-', '_', '.', ',', ':', ';', '!', '?', '@', '#', '$', '%', '^', '&', '*', '(', ')', '[', ']', '{', '}', '<', '>', '/', '\\', '|', '`', '~', '\'' => true,
        else => false,
    };
}

test "slugify: basic sentence" {
    const allocator = std.testing.allocator;
    const result = try slugify("Hello, World!", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: no trailing dash" {
    const allocator = std.testing.allocator;
    const result = try slugify("Wow!!!", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("wow", result);
}

test "slugify: skip emoji" {
    const allocator = std.testing.allocator;
    const result = try slugify("Cool 😎 Stuff", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("cool-stuff", result);
}
