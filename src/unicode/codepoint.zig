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
    try std.testing.expectEqual(CodepointClass.emoji, classifyCodepoint(0x1F600)); // 😀
}

test "latin script detection" {
    try std.testing.expect(isLatinScript('a'));
    try std.testing.expect(isLatinScript(0xE9)); // é
    try std.testing.expect(isLatinScript(0x100)); // Ā
    try std.testing.expect(!isLatinScript(0x4E00)); // 一 (Chinese)
}
