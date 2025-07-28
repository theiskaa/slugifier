const std = @import("std");

/// Iterator for processing UTF-8 codepoints safely
pub const CodepointIterator = struct {
    bytes: []const u8,
    index: usize,

    pub fn init(input: []const u8) CodepointIterator {
        return CodepointIterator{
            .bytes = input,
            .index = 0,
        };
    }

    /// Returns the next codepoint or null if at end
    pub fn next(self: *CodepointIterator) ?u21 {
        if (self.index >= self.bytes.len) {
            return null;
        }

        const byte_length = std.unicode.utf8ByteSequenceLength(self.bytes[self.index]) catch {
            self.index += 1;
            return self.next();
        };

        if (self.index + byte_length > self.bytes.len) {
            return null;
        }

        const codepoint = std.unicode.utf8Decode(self.bytes[self.index .. self.index + byte_length]) catch {
            self.index += 1;
            return self.next();
        };

        self.index += byte_length;
        return codepoint;
    }
};

/// Classifies a Unicode codepoint
pub const CodepointClass = enum {
    ascii_alphanumeric,
    ascii_separator,
    unicode_letter,
    unicode_separator,
    emoji,
    unknown,
};

/// Determines the class of a Unicode codepoint
pub fn classifyCodepoint(codepoint: u21) CodepointClass {
    if (codepoint < 128) {
        const c = @as(u8, @intCast(codepoint));
        if (std.ascii.isAlphanumeric(c)) {
            return .ascii_alphanumeric;
        }
        if (std.ascii.isWhitespace(c) or isSeparatorChar(c)) {
            return .ascii_separator;
        }
        return .unknown;
    }

    if (isLatinScript(codepoint)) return .unicode_letter;
    if (isCyrillicScript(codepoint)) return .unicode_letter;
    if (isCJKScript(codepoint)) return .unicode_letter;
    if (isRTLScript(codepoint)) return .unicode_letter;
    if (isEmoji(codepoint)) return .emoji;

    // Default to separator for unknown Unicode (will be replaced with separator)
    return .unicode_separator;
}

/// Checks if a codepoint is in the Latin script family
pub fn isLatinScript(codepoint: u21) bool {
    return switch (codepoint) {
        // Basic Latin (already handled in ASCII path)
        0x0000...0x007F => true,
        // Latin-1 Supplement
        0x0080...0x00FF => true,
        // Latin Extended-A
        0x0100...0x017F => true,
        // Latin Extended-B
        0x0180...0x024F => true,
        else => false,
    };
}

/// Checks if a codepoint is in the Cyrillic script family
pub fn isCyrillicScript(codepoint: u21) bool {
    return switch (codepoint) {
        // Cyrillic Basic
        0x0400...0x04FF => true,
        // Cyrillic Extended-A
        0x0500...0x052F => true,
        // Cyrillic Extended-B
        0x0530...0x058F => true,
        // Cyrillic Extended-C
        0x1C80...0x1C8F => true,
        // Cyrillic Extended-D
        0x1E030...0x1E08F => true,
        else => false,
    };
}

/// Checks if a codepoint is in the CJK script family
pub fn isCJKScript(codepoint: u21) bool {
    return switch (codepoint) {
        // CJK Symbols and Punctuation
        0x3000...0x303F => true,
        // Hiragana
        0x3040...0x309F => true,
        // Katakana
        0x30A0...0x30FF => true,
        // CJK Unified Ideographs
        0x4E00...0x9FFF => true,
        // Hangul Syllables
        0xAC00...0xD7AF => true,
        // Hangul Jamo
        0x1100...0x11FF => true,
        // CJK Compatibility Ideographs
        0xF900...0xFAFF => true,
        // Fullwidth and Halfwidth Forms (CJK portion)
        0xFF00...0xFFEF => true,
        // CJK Unified Ideographs Extension A
        0x3400...0x4DBF => true,
        // CJK Unified Ideographs Extension B
        0x20000...0x2A6DF => true,
        // CJK Unified Ideographs Extension C
        0x2A700...0x2B73F => true,
        // CJK Unified Ideographs Extension D
        0x2B740...0x2B81F => true,
        // CJK Unified Ideographs Extension E
        0x2B820...0x2CEAF => true,
        else => false,
    };
}

/// Checks if a codepoint is in the RTL script family (Arabic, Hebrew, etc.)
pub fn isRTLScript(codepoint: u21) bool {
    return switch (codepoint) {
        // Arabic
        0x0600...0x06FF => true, // Arabic
        0x0750...0x077F => true, // Arabic Supplement
        0x08A0...0x08FF => true, // Arabic Extended-A
        0xFB50...0xFDFF => true, // Arabic Presentation Forms-A
        0xFE70...0xFEFF => true, // Arabic Presentation Forms-B
        
        // Hebrew
        0x0590...0x05FF => true, // Hebrew
        0xFB1D...0xFB4F => true, // Hebrew Presentation Forms
        
        // Persian uses Arabic script range, covered above
        
        else => false,
    };
}

/// Basic emoji detection (simplified)
fn isEmoji(codepoint: u21) bool {
    return switch (codepoint) {
        // Emoticons
        0x1F600...0x1F64F => true,
        // Miscellaneous Symbols and Pictographs
        0x1F300...0x1F5FF => true,
        // Transport and Map Symbols
        0x1F680...0x1F6FF => true,
        // Supplemental Symbols and Pictographs
        0x1F900...0x1F9FF => true,
        else => false,
    };
}

/// Helper function for ASCII separator detection
fn isSeparatorChar(c: u8) bool {
    return switch (c) {
        '-', '_', '.', ',', ':', ';', '!', '?', '@', '#', '$', '%', '^', '&', '*', '(', ')', '[', ']', '{', '}', '<', '>', '/', '\\', '|', '`', '~', '\'' => true,
        else => false,
    };
}

test "codepoint iteration - ASCII only" {
    var iter = CodepointIterator.init("Hello");
    try std.testing.expectEqual(@as(u21, 'H'), iter.next().?);
    try std.testing.expectEqual(@as(u21, 'e'), iter.next().?);
    try std.testing.expectEqual(@as(u21, 'l'), iter.next().?);
    try std.testing.expectEqual(@as(u21, 'l'), iter.next().?);
    try std.testing.expectEqual(@as(u21, 'o'), iter.next().?);
    try std.testing.expectEqual(@as(?u21, null), iter.next());
}

test "codepoint iteration - Unicode" {
    var iter = CodepointIterator.init("Café");
    try std.testing.expectEqual(@as(u21, 'C'), iter.next().?);
    try std.testing.expectEqual(@as(u21, 'a'), iter.next().?);
    try std.testing.expectEqual(@as(u21, 'f'), iter.next().?);
    try std.testing.expectEqual(@as(u21, 0xE9), iter.next().?); // é
    try std.testing.expectEqual(@as(?u21, null), iter.next());
}

test "codepoint classification" {
    try std.testing.expectEqual(CodepointClass.ascii_alphanumeric, classifyCodepoint('a'));
    try std.testing.expectEqual(CodepointClass.ascii_alphanumeric, classifyCodepoint('1'));
    try std.testing.expectEqual(CodepointClass.ascii_separator, classifyCodepoint(' '));
    try std.testing.expectEqual(CodepointClass.ascii_separator, classifyCodepoint('-'));
    try std.testing.expectEqual(CodepointClass.unicode_letter, classifyCodepoint(0xE9)); // é
    try std.testing.expectEqual(CodepointClass.unicode_letter, classifyCodepoint(0x0410)); // А
    try std.testing.expectEqual(CodepointClass.unicode_letter, classifyCodepoint(0x0430)); // а
    try std.testing.expectEqual(CodepointClass.unicode_letter, classifyCodepoint(0x4E00)); // 一 (Chinese)
    try std.testing.expectEqual(CodepointClass.unicode_letter, classifyCodepoint(0x3042)); // あ (Hiragana)
    try std.testing.expectEqual(CodepointClass.unicode_letter, classifyCodepoint(0xAC00)); // 가 (Korean)
    try std.testing.expectEqual(CodepointClass.unicode_letter, classifyCodepoint(0x0627)); // ا (Arabic)
    try std.testing.expectEqual(CodepointClass.unicode_letter, classifyCodepoint(0x05D0)); // א (Hebrew)
    try std.testing.expectEqual(CodepointClass.emoji, classifyCodepoint(0x1F600)); // 😀
}

test "latin script detection" {
    try std.testing.expect(isLatinScript('a'));
    try std.testing.expect(isLatinScript(0xE9)); // é
    try std.testing.expect(isLatinScript(0x100)); // Ā
    try std.testing.expect(!isLatinScript(0x4E00)); // 一 (Chinese)
}

test "cyrillic script detection" {
    try std.testing.expect(isCyrillicScript(0x0410)); // А
    try std.testing.expect(isCyrillicScript(0x0430)); // а
    try std.testing.expect(isCyrillicScript(0x0404)); // Є
    try std.testing.expect(isCyrillicScript(0x0454)); // є
    try std.testing.expect(!isCyrillicScript('a')); // Latin
    try std.testing.expect(!isCyrillicScript(0x4E00)); // Chinese
}

test "cjk script detection" {
    try std.testing.expect(isCJKScript(0x4E00)); // 一 (Chinese)
    try std.testing.expect(isCJKScript(0x3042)); // あ (Hiragana)
    try std.testing.expect(isCJKScript(0x30A2)); // ア (Katakana)  
    try std.testing.expect(isCJKScript(0xAC00)); // 가 (Korean)
    try std.testing.expect(isCJKScript(0x3000)); // Ideographic space
    try std.testing.expect(isCJKScript(0xFF21)); // Fullwidth A
    try std.testing.expect(!isCJKScript('a')); // Latin
    try std.testing.expect(!isCJKScript(0x0430)); // Cyrillic
}

test "rtl script detection" {
    try std.testing.expect(isRTLScript(0x0627)); // ا (Arabic Alif)
    try std.testing.expect(isRTLScript(0x0628)); // ب (Arabic Ba)
    try std.testing.expect(isRTLScript(0x05D0)); // א (Hebrew Alef)
    try std.testing.expect(isRTLScript(0x05E9)); // ש (Hebrew Shin)
    try std.testing.expect(isRTLScript(0x067E)); // پ (Persian Pe)
    try std.testing.expect(isRTLScript(0x06F1)); // ۱ (Persian digit)
    try std.testing.expect(!isRTLScript('a')); // Latin
    try std.testing.expect(!isRTLScript(0x4E00)); // Chinese
    try std.testing.expect(!isRTLScript(0x0430)); // Cyrillic
}
