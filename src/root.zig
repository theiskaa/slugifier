const std = @import("std");
const ascii = std.ascii;

/// Text case format options for slug generation.
pub const SlugifyFormat = enum {
    /// Convert all characters to lowercase
    lowercase,
    /// Convert all characters to uppercase
    uppercase,
    /// Keep original character casing
    default,
};

/// Configuration options for slug generation.
pub const SlugifyOptions = struct {
    /// Character to use as separator between words (default: '-')
    seperator: u8 = '-',
    /// Text case format to apply (default: lowercase)
    format: SlugifyFormat = SlugifyFormat.lowercase,
};

/// Converts a string to a URL-friendly slug by keeping only alphanumeric characters
/// and replacing separator sequences with a single separator character. The function
/// applies the specified text case format and removes any leading or trailing separators.
/// Caller owns the returned memory and must free it.
pub fn slugify(input: []const u8, options: SlugifyOptions, allocator: std.mem.Allocator) ![]u8 {
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    var lastWasSeperator = false;
    for (input) |c| {
        if (ascii.isAlphanumeric(c)) {
            switch (options.format) {
                SlugifyFormat.lowercase => try buffer.append(ascii.toLower(c)),
                SlugifyFormat.uppercase => try buffer.append(ascii.toUpper(c)),
                SlugifyFormat.default => try buffer.append(c),
            }
            lastWasSeperator = false;
            continue;
        }

        if (isSeparatorChar(c) and !lastWasSeperator and buffer.items.len > 0) {
            try buffer.append(options.seperator);
            lastWasSeperator = true;
        }
    }

    if (buffer.items.len > 0 and buffer.items[buffer.items.len - 1] == options.seperator) {
        _ = buffer.pop();
    }

    return buffer.toOwnedSlice();
}

fn isSeparatorChar(c: u8) bool {
    return ascii.isWhitespace(c) or switch (c) {
        '-', '_', '.', ',', ':', ';', '!', '?', '@', '#', '$', '%', '^', '&', '*', '(', ')', '[', ']', '{', '}', '<', '>', '/', '\\', '|', '`', '~', '\'' => true,
        else => false,
    };
}

test "slugify: basic sentence with default config" {
    const allocator = std.testing.allocator;
    const result = try slugify("Hello, World!", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: basic sentence with default format and custom seperator" {
    const allocator = std.testing.allocator;
    const options = SlugifyOptions{ .format = SlugifyFormat.default, .seperator = '_' };
    const result = try slugify("Hello, World!", options, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("Hello_World", result);
}

test "slugify: no trailing dash and default config" {
    const allocator = std.testing.allocator;
    const result = try slugify("Wow!!!", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("wow", result);
}

test "slugify: skip emoji and uppercase format" {
    const allocator = std.testing.allocator;
    const result = try slugify("Cool 😎 Stuff", SlugifyOptions{ .format = SlugifyFormat.uppercase }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("COOL-STUFF", result);
}
