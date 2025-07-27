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
    separator: u8 = '-',
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

    var lastWasSeparator = false;
    for (input) |c| {
        if (ascii.isAlphanumeric(c)) {
            switch (options.format) {
                SlugifyFormat.lowercase => try buffer.append(ascii.toLower(c)),
                SlugifyFormat.uppercase => try buffer.append(ascii.toUpper(c)),
                SlugifyFormat.default => try buffer.append(c),
            }
            lastWasSeparator = false;
            continue;
        }

        if (isSeparatorChar(c) and !lastWasSeparator and buffer.items.len > 0) {
            try buffer.append(options.separator);
            lastWasSeparator = true;
        }
    }

    if (buffer.items.len > 0 and buffer.items[buffer.items.len - 1] == options.separator) {
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

test "slugify: basic sentence with default format and custom separator" {
    const allocator = std.testing.allocator;
    const options = SlugifyOptions{ .format = SlugifyFormat.default, .separator = '_' };
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

test "slugify: lowercase format" {
    const allocator = std.testing.allocator;
    const result = try slugify("HELLO World", SlugifyOptions{ .format = SlugifyFormat.lowercase }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: uppercase format" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello world", SlugifyOptions{ .format = SlugifyFormat.uppercase }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("HELLO-WORLD", result);
}

test "slugify: default format preserves case" {
    const allocator = std.testing.allocator;
    const result = try slugify("Hello WORLD", SlugifyOptions{ .format = SlugifyFormat.default }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("Hello-WORLD", result);
}

test "slugify: underscore separator" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello world", SlugifyOptions{ .separator = '_' }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello_world", result);
}

test "slugify: dot separator" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello world", SlugifyOptions{ .separator = '.' }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello.world", result);
}

test "slugify: plus separator" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello world", SlugifyOptions{ .separator = '+' }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello+world", result);
}

test "slugify: empty string" {
    const allocator = std.testing.allocator;
    const result = try slugify("", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("", result);
}

test "slugify: only separators" {
    const allocator = std.testing.allocator;
    const result = try slugify("!@#$%", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("", result);
}

test "slugify: only alphanumeric" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello123world", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello123world", result);
}

test "slugify: numbers and letters" {
    const allocator = std.testing.allocator;
    const result = try slugify("version-2.0.1", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("version-2-0-1", result);
}

test "slugify: leading separators" {
    const allocator = std.testing.allocator;
    const result = try slugify("!!!hello world", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: trailing separators" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello world!!!", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: multiple consecutive separators" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello---world", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: mixed separators" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello_world.test", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world-test", result);
}

test "slugify: single character" {
    const allocator = std.testing.allocator;
    const result = try slugify("a", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("a", result);
}

test "slugify: single separator" {
    const allocator = std.testing.allocator;
    const result = try slugify("-", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("", result);
}

test "slugify: whitespace handling" {
    const allocator = std.testing.allocator;
    const result = try slugify("  hello   world  ", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: complex mixed case with custom separator" {
    const allocator = std.testing.allocator;
    const options = SlugifyOptions{ .format = SlugifyFormat.default, .separator = '_' };
    const result = try slugify("My-AWESOME_Project.v2", options, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("My_AWESOME_Project_v2", result);
}

test "slugify: unicode and emoji removal" {
    const allocator = std.testing.allocator;
    const result = try slugify("Hello 🌍 World 👋", SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}
