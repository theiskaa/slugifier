const std = @import("std");
const config = @import("../config.zig");
const codepoint = @import("codepoint.zig");
const latin = @import("mappings/latin.zig");

/// The main transliterator engine.
/// Handles the transliteration of Unicode characters to ASCII equivalents.
pub const Transliterator = struct {
    options: config.SlugifyOptions,

    pub fn init(options: config.SlugifyOptions) Transliterator {
        return Transliterator{
            .options = options,
        };
    }

    /// Processes input text and returns a slugified string
    pub fn slugify(self: *Transliterator, input: []const u8, allocator: std.mem.Allocator) ![]u8 {
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();

        var iter = codepoint.CodepointIterator.init(input);
        var needsSeparator = false;

        while (iter.next()) |cp| {
            const class = codepoint.classifyCodepoint(cp);

            switch (class) {
                .ascii_alphanumeric => {
                    if (needsSeparator and buffer.items.len > 0) {
                        try buffer.append(self.options.separator);
                    }
                    const c = @as(u8, @intCast(cp));
                    try self.appendWithFormat(&buffer, c);
                    needsSeparator = false;
                },
                .unicode_letter => {
                    const added = try self.handleUnicodeCharacter(cp, &buffer, needsSeparator);
                    if (added) needsSeparator = false;
                },
                else => {
                    needsSeparator = true;
                },
            }
        }

        return buffer.toOwnedSlice();
    }

    /// Handle Unicode characters based on the configured mode
    fn handleUnicodeCharacter(self: *Transliterator, cp: u21, buffer: *std.ArrayList(u8), needsSeparator: bool) !bool {
        switch (self.options.unicode_mode) {
            .strip => {
                return false;
            },
            .preserve => {
                if (needsSeparator and buffer.items.len > 0) {
                    try buffer.append(self.options.separator);
                }
                if (cp < 128) {
                    const c = @as(u8, @intCast(cp));
                    try self.appendWithFormat(buffer, c);
                } else {
                    var utf8_bytes: [4]u8 = undefined;
                    const len = std.unicode.utf8Encode(cp, &utf8_bytes) catch {
                        return false;
                    };
                    try buffer.appendSlice(utf8_bytes[0..len]);
                }
                return true;
            },
            .transliterate => {
                if (self.transliterateCodepoint(cp)) |ascii_replacement| {
                    var added_any = false;
                    for (ascii_replacement) |c| {
                        if (std.ascii.isAlphanumeric(c)) {
                            if (!added_any and needsSeparator and buffer.items.len > 0) {
                                try buffer.append(self.options.separator);
                            }
                            try self.appendWithFormat(buffer, c);
                            added_any = true;
                        }
                    }
                    return added_any;
                }
                return false;
            },
        }
    }

    /// Append a character with proper case formatting
    fn appendWithFormat(self: *Transliterator, buffer: *std.ArrayList(u8), c: u8) !void {
        const formatted_char = switch (self.options.format) {
            .lowercase => std.ascii.toLower(c),
            .uppercase => std.ascii.toUpper(c),
            .default => c,
        };
        try buffer.append(formatted_char);
    }

    /// Transliterates a Unicode codepoint to ASCII equivalent if possible
    fn transliterateCodepoint(self: *Transliterator, cp: u21) ?[]const u8 {
        _ = self;

        // FIXME: we only have latting mappings for now.
        if (latin.mapLatinCodepoint(cp)) |mapping| {
            return mapping;
        }

        // TODO: Add language-specific mappings here
        // if (self.options.language) |lang| {
        //     switch (lang) {
        //         "de" => return latin.mapGermanCodepoint(cp),
        //         "fr" => return latin.mapFrenchCodepoint(cp),
        //         "es" => return latin.mapSpanishCodepoint(cp),
        //         else => {},
        //     }
        // }

        // TODO: Add other script mappings (Cyrillic, etc.)

        return null;
    }
};

test "transliterator basic ASCII" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{});

    const result = try trans.slugify("Hello World", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "transliterator unicode transliteration" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .unicode_mode = .transliterate });

    const result = try trans.slugify("Café naïve", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("cafe-naive", result);
}

test "transliterator unicode strip mode" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .unicode_mode = .strip });

    const result = try trans.slugify("Café naïve", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("caf-nave", result);
}

test "transliterator unicode preserve mode" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .unicode_mode = .preserve, .format = .default });

    const result = try trans.slugify("Café naïve", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("Café-naïve", result);
}

test "transliterator mixed content" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .unicode_mode = .transliterate });

    const result = try trans.slugify("Hello 🌍 Café! 世界", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-cafe", result);
}

test "transliterator case formatting" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .format = .uppercase, .unicode_mode = .transliterate });

    const result = try trans.slugify("Café naïve", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("CAFE-NAIVE", result);
}
