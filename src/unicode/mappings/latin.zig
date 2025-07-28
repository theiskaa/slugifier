const std = @import("std");

/// Maps a Latin Unicode codepoint to ASCII equivalent
pub fn mapLatinCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        // Latin-1 Supplement (À-ÿ) - Uppercase
        0xC0...0xC5 => "A", // À Á Â Ã Ä Å
        0xC6 => "AE", // Æ
        0xC7 => "C", // Ç
        0xC8...0xCB => "E", // È É Ê Ë
        0xCC...0xCF => "I", // Ì Í Î Ï
        0xD0 => "D", // Ð
        0xD1 => "N", // Ñ
        0xD2...0xD6 => "O", // Ò Ó Ô Õ Ö
        0xD8 => "O", // Ø
        0xD9...0xDC => "U", // Ù Ú Û Ü
        0xDD => "Y", // Ý
        0xDE => "TH", // Þ

        // Latin-1 Supplement (À-ÿ) - Lowercase
        0xDF => "ss", // ß
        0xE0...0xE5 => "a", // à á â ã ä å
        0xE6 => "ae", // æ
        0xE7 => "c", // ç
        0xE8...0xEB => "e", // è é ê ë
        0xEC...0xEF => "i", // ì í î ï
        0xF0 => "d", // ð
        0xF1 => "n", // ñ
        0xF2...0xF6 => "o", // ò ó ô õ ö
        0xF8 => "o", // ø
        0xF9...0xFC => "u", // ù ú û ü
        0xFD, 0xFF => "y", // ý ÿ
        0xFE => "th", // þ

        // Latin Extended-A (Ā-ſ) - Some common ones
        0x100, 0x102, 0x104 => "A", // Ā Ă Ą
        0x101, 0x103, 0x105 => "a", // ā ă ą
        0x106, 0x108, 0x10A, 0x10C => "C", // Ć Ĉ Ċ Č
        0x107, 0x109, 0x10B, 0x10D => "c", // ć ĉ ċ č
        0x10E, 0x110 => "D", // Ď Đ
        0x10F, 0x111 => "d", // ď đ
        0x112, 0x114, 0x116, 0x118, 0x11A => "E", // Ē Ĕ Ė Ę Ě
        0x113, 0x115, 0x117, 0x119, 0x11B => "e", // ē ĕ ė ę ě
        0x11C, 0x11E, 0x120, 0x122 => "G", // Ĝ Ğ Ġ Ģ
        0x11D, 0x11F, 0x121, 0x123 => "g", // ĝ ğ ġ ģ
        0x124, 0x126 => "H", // Ĥ Ħ
        0x125, 0x127 => "h", // ĥ ħ
        0x128, 0x12A, 0x12C, 0x12E, 0x130 => "I", // Ĩ Ī Ĭ Į İ
        0x129, 0x12B, 0x12D, 0x12F, 0x131 => "i", // ĩ ī ĭ į ı
        0x134 => "J", // Ĵ
        0x135 => "j", // ĵ
        0x136 => "K", // Ķ
        0x137 => "k", // ķ
        0x139, 0x13B, 0x13D, 0x13F, 0x141 => "L", // Ĺ Ļ Ľ Ŀ Ł
        0x13A, 0x13C, 0x13E, 0x140, 0x142 => "l", // ĺ ļ ľ ŀ ł
        0x143, 0x145, 0x147 => "N", // Ń Ņ Ň
        0x144, 0x146, 0x148 => "n", // ń ņ ň
        0x14C, 0x14E, 0x150 => "O", // Ō Ŏ Ő
        0x14D, 0x14F, 0x151 => "o", // ō ŏ ő
        0x152 => "OE", // Œ
        0x153 => "oe", // œ
        0x154, 0x156, 0x158 => "R", // Ŕ Ř Ř
        0x155, 0x157, 0x159 => "r", // ŕ ŗ ř
        0x15A, 0x15C, 0x15E, 0x160 => "S", // Ś Ŝ Ş Š
        0x15B, 0x15D, 0x15F, 0x161 => "s", // ś ŝ ş š
        0x162, 0x164, 0x166 => "T", // Ţ Ť Ŧ
        0x163, 0x165, 0x167 => "t", // ţ ť ŧ
        0x168, 0x16A, 0x16C, 0x16E, 0x170, 0x172 => "U", // Ũ Ū Ŭ Ů Ű Ų
        0x169, 0x16B, 0x16D, 0x16F, 0x171, 0x173 => "u", // ũ ū ŭ ů ű ų
        0x174 => "W", // Ŵ
        0x175 => "w", // ŵ
        0x176, 0x178 => "Y", // Ŷ Ÿ
        0x177 => "y", // ŷ
        0x179, 0x17B, 0x17D => "Z", // Ź Ż Ž
        0x17A, 0x17C, 0x17E => "z", // ź ż ž

        else => null,
    };
}

/// German-specific character mappings (overrides generic Latin mappings)
pub fn mapGermanCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        0xDC => "UE", // Ü -> UE
        0xFC => "ue", // ü -> ue
        0xD6 => "OE", // Ö -> OE
        0xF6 => "oe", // ö -> oe
        0xC4 => "AE", // Ä -> AE
        0xE4 => "ae", // ä -> ae
        0xDF => "ss", // ß -> ss
        else => null,
    };
}

/// French-specific character mappings (mostly same as generic Latin)
pub fn mapFrenchCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        0x152 => "OE", // Œ -> OE
        0x153 => "oe", // œ -> oe
        else => null,
    };
}

/// Spanish-specific character mappings (mostly same as generic Latin)
pub fn mapSpanishCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        0xD1 => "N", // Ñ -> N
        0xF1 => "n", // ñ -> n
        else => null,
    };
}

test "latin mappings - basic accents" {
    try std.testing.expectEqualStrings("a", mapLatinCodepoint(0xE0).?); // à
    try std.testing.expectEqualStrings("e", mapLatinCodepoint(0xE9).?); // é
    try std.testing.expectEqualStrings("i", mapLatinCodepoint(0xED).?); // í
    try std.testing.expectEqualStrings("o", mapLatinCodepoint(0xF3).?); // ó
    try std.testing.expectEqualStrings("u", mapLatinCodepoint(0xFA).?); // ú
}

test "latin mappings - uppercase accents" {
    try std.testing.expectEqualStrings("A", mapLatinCodepoint(0xC0).?); // À
    try std.testing.expectEqualStrings("E", mapLatinCodepoint(0xC9).?); // É
    try std.testing.expectEqualStrings("I", mapLatinCodepoint(0xCD).?); // Í
    try std.testing.expectEqualStrings("O", mapLatinCodepoint(0xD3).?); // Ó
    try std.testing.expectEqualStrings("U", mapLatinCodepoint(0xDA).?); // Ú
}

test "latin mappings - special characters" {
    try std.testing.expectEqualStrings("C", mapLatinCodepoint(0xC7).?); // Ç
    try std.testing.expectEqualStrings("c", mapLatinCodepoint(0xE7).?); // ç
    try std.testing.expectEqualStrings("N", mapLatinCodepoint(0xD1).?); // Ñ
    try std.testing.expectEqualStrings("n", mapLatinCodepoint(0xF1).?); // ñ
    try std.testing.expectEqualStrings("ss", mapLatinCodepoint(0xDF).?); // ß
}

test "latin mappings - extended characters" {
    try std.testing.expectEqualStrings("A", mapLatinCodepoint(0x100).?); // Ā
    try std.testing.expectEqualStrings("a", mapLatinCodepoint(0x101).?); // ā
    try std.testing.expectEqualStrings("C", mapLatinCodepoint(0x106).?); // Ć
    try std.testing.expectEqualStrings("c", mapLatinCodepoint(0x107).?); // ć
}

test "german mappings" {
    try std.testing.expectEqualStrings("ue", mapGermanCodepoint(0xFC).?); // ü
    try std.testing.expectEqualStrings("oe", mapGermanCodepoint(0xF6).?); // ö
    try std.testing.expectEqualStrings("ae", mapGermanCodepoint(0xE4).?); // ä
    try std.testing.expectEqualStrings("ss", mapGermanCodepoint(0xDF).?); // ß
}

test "unmapped characters return null" {
    try std.testing.expectEqual(@as(?[]const u8, null), mapLatinCodepoint(0x4E00)); // Chinese character
    try std.testing.expectEqual(@as(?[]const u8, null), mapLatinCodepoint('a')); // Regular ASCII
}
