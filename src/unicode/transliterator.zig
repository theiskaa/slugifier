const std = @import("std");
const config = @import("../config.zig");
const codepoint = @import("codepoint.zig");
const latin = @import("mappings/latin.zig");
const cyrillic = @import("mappings/cyrillic.zig");
const cjk = @import("mappings/cjk.zig");
const rtl = @import("mappings/rtl.zig");

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

        var result = try buffer.toOwnedSlice();
        if (self.options.max_length) |max_len| {
            result = try self.truncate(result, max_len, allocator);
        }

        return result;
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
        if (self.options.language) |lang| {
            const lang_mapping = switch (lang) {
                .de => latin.mapGermanCodepoint(cp),
                .fr => latin.mapFrenchCodepoint(cp),
                .es => latin.mapSpanishCodepoint(cp),
                .ru => cyrillic.mapRussianCodepoint(cp),
                .uk => cyrillic.mapUkrainianCodepoint(cp),
                .it => latin.mapItalianCodepoint(cp),
                .pt => latin.mapPortugueseCodepoint(cp),
                .nl => latin.mapDutchCodepoint(cp),
                .pl => latin.mapPolishCodepoint(cp),
                .cz => latin.mapCzechCodepoint(cp),
                .be => cyrillic.mapBelarusianCodepoint(cp),
                .sr => cyrillic.mapSerbianCodepoint(cp),
                .sv => latin.mapSwedishCodepoint(cp),
                .no => latin.mapNorwegianCodepoint(cp),
                .da => latin.mapDanishCodepoint(cp),
                .fi => latin.mapFinnishCodepoint(cp),
                .zh => cjk.mapChineseCodepoint(cp),
                .ja => cjk.mapJapaneseCodepoint(cp),
                .ko => cjk.mapKoreanCodepoint(cp),
                .ar => rtl.mapArabicCodepoint(cp),
                .he => rtl.mapHebrewCodepoint(cp),
                .fa => rtl.mapPersianCodepoint(cp),
            };
            if (lang_mapping) |mapping| return mapping;
        }

        if (latin.mapLatinCodepoint(cp)) |mapping| return mapping;
        if (cyrillic.mapCyrillicCodepoint(cp)) |mapping| return mapping;
        if (cjk.mapCJKCodepoint(cp)) |mapping| return mapping;
        if (rtl.mapRTLCodepoint(cp)) |mapping| return mapping;

        return null;
    }

    fn truncate(self: *Transliterator, slug: []u8, max_length: usize, allocator: std.mem.Allocator) ![]u8 {
        if (slug.len <= max_length) return slug;

        if (max_length == 0) {
            allocator.free(slug);
            return try allocator.dupe(u8, "");
        }

        var last_separator_pos: ?usize = null;
        var i: usize = 0;
        while (i < slug.len and i < max_length) : (i += 1) {
            if (slug[i] == self.options.separator) {
                last_separator_pos = i;
            }
        }

        const truncate_at = if (last_separator_pos) |pos| blk: {
            break :blk pos;
        } else blk: {
            break :blk max_length;
        };

        const truncated = try allocator.dupe(u8, slug[0..truncate_at]);
        allocator.free(slug);

        return truncated;
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

test "transliterator cyrillic transliteration" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .unicode_mode = .transliterate });

    const result = try trans.slugify("Привет мир", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("privet-mir", result);
}

test "transliterator mixed cyrillic and latin" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .unicode_mode = .transliterate });

    const result = try trans.slugify("Hello Привет World", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-privet-world", result);
}

test "transliterator ukrainian characters" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .uk,
    });

    const result = try trans.slugify("Привіт світ", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("privit-svit", result);
}

test "transliterator language-specific german" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .de,
    });

    const result = try trans.slugify("Müllerstraße", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("muellerstrasse", result);
}

test "transliterator language-specific french" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .fr,
    });

    const result = try trans.slugify("Cœur et Âme", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("coeur-et-ame", result);
}

test "transliterator language-specific spanish" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .es,
    });

    const result = try trans.slugify("Niño y Señor", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("nino-y-senor", result);
}

test "transliterator language-specific russian" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .ru,
    });

    const result = try trans.slugify("Привет мир", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("privet-mir", result);
}

test "transliterator language-specific ukrainian" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .uk,
    });

    const result = try trans.slugify("Привіт світ", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("privit-svit", result);
}

test "transliterator language-specific polish" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .pl,
    });

    const result = try trans.slugify("Łódź i Warszawa", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("lodz-i-warszawa", result);
}

test "transliterator language-specific belarusian" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .be,
    });

    const result = try trans.slugify("Прывітанне свет", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("pryvitanne-svet", result);
}

test "transliterator language-specific serbian" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .sr,
    });

    const result = try trans.slugify("Здраво свете", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("zdravo-svete", result);
}

test "transliterator language-specific czech" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .cz,
    });

    const result = try trans.slugify("Čeština řeč", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("cestina-rec", result);
}

test "transliterator language-specific swedish" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .sv,
    });

    const result = try trans.slugify("Åsa och Östen", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("asa-och-osten", result);
}

test "transliterator language-specific norwegian" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .no,
    });

    const result = try trans.slugify("Øl og Æbler", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("ol-og-aebler", result);
}

test "transliterator language-specific danish" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .da,
    });

    const result = try trans.slugify("Køb Æbler", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("kob-aebler", result);
}

test "transliterator language-specific finnish" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .fi,
    });

    const result = try trans.slugify("Äiti ja Öljy", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("aiti-ja-oljy", result);
}

test "transliterator language-specific chinese" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .zh,
    });

    const result = try trans.slugify("你好 大", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("nihao-da", result);
}

test "transliterator language-specific japanese" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .ja,
    });

    const result = try trans.slugify("こんにちは", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("konnichiha", result);
}

test "transliterator language-specific korean" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .ko,
    });

    const result = try trans.slugify("안 한국", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("an-hangug", result);
}

test "transliterator fallback to generic mappings" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .de, // German language specified
    });

    // Test that non-German characters still get transliterated using generic mappings
    const result = try trans.slugify("Café naïve", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("cafe-naive", result);
}

test "transliterator mixed scripts with language" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .ru,
    });

    const result = try trans.slugify("Hello Привет World", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-privet-world", result);
}

test "transliterator case formatting with language" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .de,
        .format = .uppercase,
    });

    const result = try trans.slugify("Müllerstraße", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("MUELLERSTRASSE", result);
}

test "transliterator custom separator with language" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .fr,
        .separator = '_',
    });

    const result = try trans.slugify("Cœur et Âme", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("coeur_et_ame", result);
}

test "transliterator comprehensive language support" {
    const allocator = std.testing.allocator;

    // Test all supported languages
    const test_cases = [_]struct {
        language: config.Language,
        input: []const u8,
        expected: []const u8,
    }{
        .{ .language = .de, .input = "Müllerstraße", .expected = "muellerstrasse" },
        .{ .language = .fr, .input = "Cœur et Âme", .expected = "coeur-et-ame" },
        .{ .language = .es, .input = "Niño y Señor", .expected = "nino-y-senor" },
        .{ .language = .ru, .input = "Привет мир", .expected = "privet-mir" },
        .{ .language = .uk, .input = "Привіт світ", .expected = "privit-svit" },
        .{ .language = .pl, .input = "Łódź i Warszawa", .expected = "lodz-i-warszawa" },
        .{ .language = .cz, .input = "Čeština řeč", .expected = "cestina-rec" },
        .{ .language = .be, .input = "Прывітанне свет", .expected = "pryvitanne-svet" },
        .{ .language = .sr, .input = "Здраво свете", .expected = "zdravo-svete" },
        .{ .language = .sv, .input = "Åsa och Östen", .expected = "asa-och-osten" },
        .{ .language = .no, .input = "Øl og Æbler", .expected = "ol-og-aebler" },
        .{ .language = .da, .input = "Køb Æbler", .expected = "kob-aebler" },
        .{ .language = .fi, .input = "Äiti ja Öljy", .expected = "aiti-ja-oljy" },
        .{ .language = .zh, .input = "你好 大", .expected = "nihao-da" },
        .{ .language = .ja, .input = "こんにちは", .expected = "konnichiha" },
        .{ .language = .ko, .input = "안 한국", .expected = "an-hangug" },
        .{ .language = .ar, .input = "سلام العالم", .expected = "slam-alalm" },
        .{ .language = .he, .input = "שלום הבה", .expected = "shlvm-hbh" },
        .{ .language = .fa, .input = "سلام پارسی", .expected = "slam-parsi" },
    };

    for (test_cases) |case| {
        var trans = Transliterator.init(config.SlugifyOptions{
            .unicode_mode = .transliterate,
            .language = case.language,
        });

        const result = try trans.slugify(case.input, allocator);
        defer allocator.free(result);
        try std.testing.expectEqualStrings(case.expected, result);
    }
}

test "transliterator fallback behavior" {
    const allocator = std.testing.allocator;

    // Test that when no language is specified, it falls back to generic mappings
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
    });

    const result = try trans.slugify("Café naïve Привет", allocator);
    defer allocator.free(result);
    // Should transliterate both Latin and Cyrillic characters using generic mappings
    try std.testing.expectEqualStrings("cafe-naive-privet", result);
}

test "transliterator mixed language content" {
    const allocator = std.testing.allocator;

    // Test mixed content with language specification
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .ru,
    });

    const result = try trans.slugify("Hello Привет World", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-privet-world", result);
}

test "transliterator cjk fallback behavior" {
    const allocator = std.testing.allocator;

    // Test CJK characters with generic mappings (no language specified)
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
    });

    const result = try trans.slugify("Hello! World こんにちは", allocator);
    defer allocator.free(result);
    // CJK characters with no language specified use generic mappings, hiragana maps to romaji
    try std.testing.expectEqualStrings("hello-world-konnichiha", result);
}

test "transliterator mixed cjk content" {
    const allocator = std.testing.allocator;

    // Test mixed CJK content with Chinese language specified
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .zh,
    });

    const result = try trans.slugify("Hello 你好 World", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-nihao-world", result);
}

test "transliterator language-specific arabic" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .ar,
    });

    const result = try trans.slugify("سلام العالم", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("slam-alalm", result);
}

test "transliterator language-specific hebrew" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .he,
    });

    const result = try trans.slugify("שלום הבה", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("shlvm-hbh", result);
}

test "transliterator language-specific persian" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .fa,
    });

    const result = try trans.slugify("سلام پارسی", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("slam-parsi", result);
}

test "transliterator rtl fallback behavior" {
    const allocator = std.testing.allocator;

    // Test RTL characters with generic mappings (no language specified)
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
    });

    const result = try trans.slugify("Hello سلام World", allocator);
    defer allocator.free(result);
    // Should use generic RTL mappings (tries Hebrew, then Arabic, then Persian)
    try std.testing.expectEqualStrings("hello-slam-world", result);
}

test "transliterator mixed rtl content" {
    const allocator = std.testing.allocator;

    // Test mixed RTL content with Arabic language specified
    var trans = Transliterator.init(config.SlugifyOptions{
        .unicode_mode = .transliterate,
        .language = .ar,
    });

    const result = try trans.slugify("Hello سلام World", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-slam-world", result);
}

test "smart truncation - no truncation needed" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .max_length = 20 });

    const result = try trans.slugify("Hello World", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-world", result);
}

test "smart truncation - truncate at word boundary" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .max_length = 10 });

    const result = try trans.slugify("Hello World Test", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello", result);
}

test "smart truncation - exact boundary" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .max_length = 10 });

    const result = try trans.slugify("Hello World", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello", result);
}

test "smart truncation - no separators" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .max_length = 5 });

    const result = try trans.slugify("HelloWorld", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello", result);
}

test "smart truncation - very short limit" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .max_length = 2 });

    const result = try trans.slugify("Hello World", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("he", result);
}

test "smart truncation - zero length" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .max_length = 0 });

    const result = try trans.slugify("Hello World", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("", result);
}

test "smart truncation - with unicode" {
    const allocator = std.testing.allocator;
    var trans = Transliterator.init(config.SlugifyOptions{ .max_length = 15, .unicode_mode = .transliterate, .language = .zh });

    const result = try trans.slugify("Hello 你好 World", allocator);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello-nihao", result);
}
