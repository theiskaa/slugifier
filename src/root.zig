const std = @import("std");
const ascii = std.ascii;
const config = @import("config.zig");
const transliterator = @import("unicode/transliterator.zig");

/// Converts a string to a URL-friendly slug by keeping only alphanumeric characters
/// and replacing separator sequences with a single separator character. The function
/// applies the specified text case format and removes any leading or trailing separators.
/// Now supports Unicode characters with proper transliteration.
/// Caller owns the returned memory and must free it.
pub fn slugify(input: []const u8, options: config.SlugifyOptions, allocator: std.mem.Allocator) ![]u8 {
    try options.validate();

    // Contributors, please don't rename this variable :D
    var trans = transliterator.Transliterator.init(options);
    return trans.slugify(input, allocator);
}

test "slugify: basic sentence with default config" {
    const allocator = std.testing.allocator;
    const result = try slugify("Hello, World!", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: basic sentence with default format and custom separator" {
    const allocator = std.testing.allocator;
    const options = config.SlugifyOptions{ .format = config.SlugifyFormat.default, .separator = '_' };
    const result = try slugify("Hello, World!", options, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("Hello_World", result);
}

test "slugify: no trailing dash and default config" {
    const allocator = std.testing.allocator;
    const result = try slugify("Wow!!!", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("wow", result);
}

test "slugify: skip emoji and uppercase format" {
    const allocator = std.testing.allocator;
    const result = try slugify("Cool 😎 Stuff", config.SlugifyOptions{ .format = config.SlugifyFormat.uppercase }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("COOL-STUFF", result);
}

test "slugify: lowercase format" {
    const allocator = std.testing.allocator;
    const result = try slugify("HELLO World", config.SlugifyOptions{ .format = config.SlugifyFormat.lowercase }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: uppercase format" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello world", config.SlugifyOptions{ .format = config.SlugifyFormat.uppercase }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("HELLO-WORLD", result);
}

test "slugify: default format preserves case" {
    const allocator = std.testing.allocator;
    const result = try slugify("Hello WORLD", config.SlugifyOptions{ .format = config.SlugifyFormat.default }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("Hello-WORLD", result);
}

test "slugify: underscore separator" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello world", config.SlugifyOptions{ .separator = '_' }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello_world", result);
}

test "slugify: dot separator" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello world", config.SlugifyOptions{ .separator = '.' }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello.world", result);
}

test "slugify: plus separator" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello world", config.SlugifyOptions{ .separator = '+' }, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello+world", result);
}

test "slugify: empty string" {
    const allocator = std.testing.allocator;
    const result = try slugify("", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("", result);
}

test "slugify: only separators" {
    const allocator = std.testing.allocator;
    const result = try slugify("!@#$%", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("", result);
}

test "slugify: only alphanumeric" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello123world", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello123world", result);
}

test "slugify: numbers and letters" {
    const allocator = std.testing.allocator;
    const result = try slugify("version-2.0.1", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("version-2-0-1", result);
}

test "slugify: leading separators" {
    const allocator = std.testing.allocator;
    const result = try slugify("!!!hello world", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: trailing separators" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello world!!!", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: multiple consecutive separators" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello---world", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: mixed separators" {
    const allocator = std.testing.allocator;
    const result = try slugify("hello_world.test", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world-test", result);
}

test "slugify: single character" {
    const allocator = std.testing.allocator;
    const result = try slugify("a", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("a", result);
}

test "slugify: single separator" {
    const allocator = std.testing.allocator;
    const result = try slugify("-", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("", result);
}

test "slugify: whitespace handling" {
    const allocator = std.testing.allocator;
    const result = try slugify("  hello   world  ", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "slugify: complex mixed case with custom separator" {
    const allocator = std.testing.allocator;
    const options = config.SlugifyOptions{ .format = config.SlugifyFormat.default, .separator = '_' };
    const result = try slugify("My-AWESOME_Project.v2", options, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("My_AWESOME_Project_v2", result);
}

test "slugify: unicode and emoji removal" {
    const allocator = std.testing.allocator;
    const result = try slugify("Hello 🌍 World 👋", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

// New Unicode-specific tests
test "slugify: unicode transliteration - basic accents" {
    const allocator = std.testing.allocator;
    const result = try slugify("Café naïve résumé", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("cafe-naive-resume", result);
}

test "slugify: unicode transliteration - mixed case" {
    const allocator = std.testing.allocator;
    const options = config.SlugifyOptions{ .format = .default };
    const result = try slugify("CAFÉ et Naïve", options, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("CAFE-et-Naive", result);
}

test "slugify: unicode strip mode" {
    const allocator = std.testing.allocator;
    const options = config.SlugifyOptions{ .unicode_mode = .strip };
    const result = try slugify("Café naïve", options, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("caf-nave", result);
}

test "slugify: unicode preserve mode" {
    const allocator = std.testing.allocator;
    const options = config.SlugifyOptions{ .unicode_mode = .preserve, .format = .default };
    const result = try slugify("Café naïve", options, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("Café-naïve", result);
}

test "slugify: extended latin characters" {
    const allocator = std.testing.allocator;
    const result = try slugify("Ćirilo Đorđević", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("cirilo-dordevic", result);
}

test "slugify: complex unicode input" {
    const allocator = std.testing.allocator;
    const result = try slugify("Schöne Grüße aus München!", config.SlugifyOptions{}, allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("schone-grusse-aus-munchen", result);
}
