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

/// Italian-specific character mappings
pub fn mapItalianCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        // Italian doesn't have many special characters beyond standard Latin
        // Most Italian characters are handled by the generic Latin mappings
        else => null,
    };
}

/// Portuguese-specific character mappings
pub fn mapPortugueseCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        // Portuguese uses mostly standard Latin characters
        // Some regional variations might need specific handling
        else => null,
    };
}

/// Dutch-specific character mappings
pub fn mapDutchCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        // Dutch uses mostly standard Latin characters
        // The IJ digraph is typically handled as two separate letters
        else => null,
    };
}

/// Polish-specific character mappings
pub fn mapPolishCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        0x0104 => "A", // Ą -> A
        0x0105 => "a", // ą -> a
        0x0106 => "C", // Ć -> C
        0x0107 => "c", // ć -> c
        0x0118 => "E", // Ę -> E
        0x0119 => "e", // ę -> e
        0x0141 => "L", // Ł -> L
        0x0142 => "l", // ł -> l
        0x0143 => "N", // Ń -> N
        0x0144 => "n", // ń -> n
        0x00D3 => "O", // Ó -> O
        0x00F3 => "o", // ó -> o
        0x015A => "S", // Ś -> S
        0x015B => "s", // ś -> s
        0x0179 => "Z", // Ź -> Z
        0x017A => "z", // ź -> z
        0x017B => "Z", // Ż -> Z
        0x017C => "z", // ż -> z
        else => null,
    };
}

/// Czech-specific character mappings
pub fn mapCzechCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        0x00C1 => "A", // Á -> A
        0x00E1 => "a", // á -> a
        0x010C => "C", // Č -> C
        0x010D => "c", // č -> c
        0x010E => "D", // Ď -> D
        0x010F => "d", // ď -> d
        0x00C9 => "E", // É -> E
        0x00E9 => "e", // é -> e
        0x011A => "E", // Ě -> E
        0x011B => "e", // ě -> e
        0x00CD => "I", // Í -> I
        0x00ED => "i", // í -> i
        0x0147 => "N", // Ň -> N
        0x0148 => "n", // ň -> n
        0x00D3 => "O", // Ó -> O
        0x00F3 => "o", // ó -> o
        0x0158 => "R", // Ř -> R
        0x0159 => "r", // ř -> r
        0x0160 => "S", // Š -> S
        0x0161 => "s", // š -> s
        0x0164 => "T", // Ť -> T
        0x0165 => "t", // ť -> t
        0x00DA => "U", // Ú -> U
        0x00FA => "u", // ú -> u
        0x016E => "U", // Ů -> U
        0x016F => "u", // ů -> u
        0x00DD => "Y", // Ý -> Y
        0x00FD => "y", // ý -> y
        0x017D => "Z", // Ž -> Z
        0x017E => "z", // ž -> z
        else => null,
    };
}

/// Swedish-specific character mappings
pub fn mapSwedishCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        0x00C5 => "A", // Å -> A
        0x00E5 => "a", // å -> a
        0x00C4 => "A", // Ä -> A
        0x00E4 => "a", // ä -> a
        0x00D6 => "O", // Ö -> O
        0x00F6 => "o", // ö -> o
        else => null,
    };
}

/// Norwegian-specific character mappings
pub fn mapNorwegianCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        0x00C5 => "A", // Å -> A
        0x00E5 => "a", // å -> a
        0x00C6 => "AE", // Æ -> AE
        0x00E6 => "ae", // æ -> ae
        0x00D8 => "O", // Ø -> O
        0x00F8 => "o", // ø -> o
        else => null,
    };
}

/// Danish-specific character mappings
pub fn mapDanishCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        0x00C5 => "A", // Å -> A
        0x00E5 => "a", // å -> a
        0x00C6 => "AE", // Æ -> AE
        0x00E6 => "ae", // æ -> ae
        0x00D8 => "O", // Ø -> O
        0x00F8 => "o", // ø -> o
        else => null,
    };
}

/// Finnish-specific character mappings
pub fn mapFinnishCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        0x00C4 => "A", // Ä -> A
        0x00E4 => "a", // ä -> a
        0x00D6 => "O", // Ö -> O
        0x00F6 => "o", // ö -> o
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

test "italian mappings" {
    // Italian mostly uses standard Latin mappings
    try std.testing.expectEqual(@as(?[]const u8, null), mapItalianCodepoint(0x00E0)); // à
    try std.testing.expectEqual(@as(?[]const u8, null), mapItalianCodepoint(0x00E9)); // é
}

test "portuguese mappings" {
    // Portuguese mostly uses standard Latin mappings
    try std.testing.expectEqual(@as(?[]const u8, null), mapPortugueseCodepoint(0x00E7)); // ç
    try std.testing.expectEqual(@as(?[]const u8, null), mapPortugueseCodepoint(0x00E3)); // ã
}

test "dutch mappings" {
    // Dutch mostly uses standard Latin mappings
    try std.testing.expectEqual(@as(?[]const u8, null), mapDutchCodepoint(0x00EB)); // ë
    try std.testing.expectEqual(@as(?[]const u8, null), mapDutchCodepoint(0x00EF)); // ï
}

test "polish mappings" {
    try std.testing.expectEqualStrings("A", mapPolishCodepoint(0x0104).?); // Ą
    try std.testing.expectEqualStrings("a", mapPolishCodepoint(0x0105).?); // ą
    try std.testing.expectEqualStrings("C", mapPolishCodepoint(0x0106).?); // Ć
    try std.testing.expectEqualStrings("c", mapPolishCodepoint(0x0107).?); // ć
    try std.testing.expectEqualStrings("E", mapPolishCodepoint(0x0118).?); // Ę
    try std.testing.expectEqualStrings("e", mapPolishCodepoint(0x0119).?); // ę
    try std.testing.expectEqualStrings("L", mapPolishCodepoint(0x0141).?); // Ł
    try std.testing.expectEqualStrings("l", mapPolishCodepoint(0x0142).?); // ł
    try std.testing.expectEqualStrings("N", mapPolishCodepoint(0x0143).?); // Ń
    try std.testing.expectEqualStrings("n", mapPolishCodepoint(0x0144).?); // ń
    try std.testing.expectEqualStrings("O", mapPolishCodepoint(0x00D3).?); // Ó
    try std.testing.expectEqualStrings("o", mapPolishCodepoint(0x00F3).?); // ó
    try std.testing.expectEqualStrings("S", mapPolishCodepoint(0x015A).?); // Ś
    try std.testing.expectEqualStrings("s", mapPolishCodepoint(0x015B).?); // ś
    try std.testing.expectEqualStrings("Z", mapPolishCodepoint(0x0179).?); // Ź
    try std.testing.expectEqualStrings("z", mapPolishCodepoint(0x017A).?); // ź
    try std.testing.expectEqualStrings("Z", mapPolishCodepoint(0x017B).?); // Ż
    try std.testing.expectEqualStrings("z", mapPolishCodepoint(0x017C).?); // ż
}

test "czech mappings" {
    // Test all Czech-specific characters
    try std.testing.expectEqualStrings("A", mapCzechCodepoint(0x00C1).?); // Á
    try std.testing.expectEqualStrings("a", mapCzechCodepoint(0x00E1).?); // á
    try std.testing.expectEqualStrings("C", mapCzechCodepoint(0x010C).?); // Č
    try std.testing.expectEqualStrings("c", mapCzechCodepoint(0x010D).?); // č
    try std.testing.expectEqualStrings("D", mapCzechCodepoint(0x010E).?); // Ď
    try std.testing.expectEqualStrings("d", mapCzechCodepoint(0x010F).?); // ď
    try std.testing.expectEqualStrings("E", mapCzechCodepoint(0x00C9).?); // É
    try std.testing.expectEqualStrings("e", mapCzechCodepoint(0x00E9).?); // é
    try std.testing.expectEqualStrings("E", mapCzechCodepoint(0x011A).?); // Ě
    try std.testing.expectEqualStrings("e", mapCzechCodepoint(0x011B).?); // ě
    try std.testing.expectEqualStrings("I", mapCzechCodepoint(0x00CD).?); // Í
    try std.testing.expectEqualStrings("i", mapCzechCodepoint(0x00ED).?); // í
    try std.testing.expectEqualStrings("N", mapCzechCodepoint(0x0147).?); // Ň
    try std.testing.expectEqualStrings("n", mapCzechCodepoint(0x0148).?); // ň
    try std.testing.expectEqualStrings("O", mapCzechCodepoint(0x00D3).?); // Ó
    try std.testing.expectEqualStrings("o", mapCzechCodepoint(0x00F3).?); // ó
    try std.testing.expectEqualStrings("R", mapCzechCodepoint(0x0158).?); // Ř
    try std.testing.expectEqualStrings("r", mapCzechCodepoint(0x0159).?); // ř
    try std.testing.expectEqualStrings("S", mapCzechCodepoint(0x0160).?); // Š
    try std.testing.expectEqualStrings("s", mapCzechCodepoint(0x0161).?); // š
    try std.testing.expectEqualStrings("T", mapCzechCodepoint(0x0164).?); // Ť
    try std.testing.expectEqualStrings("t", mapCzechCodepoint(0x0165).?); // ť
    try std.testing.expectEqualStrings("U", mapCzechCodepoint(0x00DA).?); // Ú
    try std.testing.expectEqualStrings("u", mapCzechCodepoint(0x00FA).?); // ú
    try std.testing.expectEqualStrings("U", mapCzechCodepoint(0x016E).?); // Ů
    try std.testing.expectEqualStrings("u", mapCzechCodepoint(0x016F).?); // ů
    try std.testing.expectEqualStrings("Y", mapCzechCodepoint(0x00DD).?); // Ý
    try std.testing.expectEqualStrings("y", mapCzechCodepoint(0x00FD).?); // ý
    try std.testing.expectEqualStrings("Z", mapCzechCodepoint(0x017D).?); // Ž
    try std.testing.expectEqualStrings("z", mapCzechCodepoint(0x017E).?); // ž
    
    // Test that non-Czech characters return null
    try std.testing.expectEqual(@as(?[]const u8, null), mapCzechCodepoint('a')); // Regular ASCII
    try std.testing.expectEqual(@as(?[]const u8, null), mapCzechCodepoint(0x4E00)); // Chinese character
}

test "swedish mappings" {
    // Test all Swedish-specific characters
    try std.testing.expectEqualStrings("A", mapSwedishCodepoint(0x00C5).?); // Å
    try std.testing.expectEqualStrings("a", mapSwedishCodepoint(0x00E5).?); // å
    try std.testing.expectEqualStrings("A", mapSwedishCodepoint(0x00C4).?); // Ä
    try std.testing.expectEqualStrings("a", mapSwedishCodepoint(0x00E4).?); // ä
    try std.testing.expectEqualStrings("O", mapSwedishCodepoint(0x00D6).?); // Ö
    try std.testing.expectEqualStrings("o", mapSwedishCodepoint(0x00F6).?); // ö
    
    // Test that non-Swedish characters return null
    try std.testing.expectEqual(@as(?[]const u8, null), mapSwedishCodepoint('a')); // Regular ASCII
    try std.testing.expectEqual(@as(?[]const u8, null), mapSwedishCodepoint(0x00C6)); // Æ (Norwegian/Danish)
}

test "norwegian mappings" {
    // Test all Norwegian-specific characters
    try std.testing.expectEqualStrings("A", mapNorwegianCodepoint(0x00C5).?); // Å
    try std.testing.expectEqualStrings("a", mapNorwegianCodepoint(0x00E5).?); // å
    try std.testing.expectEqualStrings("AE", mapNorwegianCodepoint(0x00C6).?); // Æ
    try std.testing.expectEqualStrings("ae", mapNorwegianCodepoint(0x00E6).?); // æ
    try std.testing.expectEqualStrings("O", mapNorwegianCodepoint(0x00D8).?); // Ø
    try std.testing.expectEqualStrings("o", mapNorwegianCodepoint(0x00F8).?); // ø
    
    // Test that non-Norwegian characters return null
    try std.testing.expectEqual(@as(?[]const u8, null), mapNorwegianCodepoint('a')); // Regular ASCII
    try std.testing.expectEqual(@as(?[]const u8, null), mapNorwegianCodepoint(0x00C4)); // Ä (Swedish/Finnish)
}

test "danish mappings" {
    // Test all Danish-specific characters (same as Norwegian)
    try std.testing.expectEqualStrings("A", mapDanishCodepoint(0x00C5).?); // Å
    try std.testing.expectEqualStrings("a", mapDanishCodepoint(0x00E5).?); // å
    try std.testing.expectEqualStrings("AE", mapDanishCodepoint(0x00C6).?); // Æ
    try std.testing.expectEqualStrings("ae", mapDanishCodepoint(0x00E6).?); // æ
    try std.testing.expectEqualStrings("O", mapDanishCodepoint(0x00D8).?); // Ø
    try std.testing.expectEqualStrings("o", mapDanishCodepoint(0x00F8).?); // ø
    
    // Test that non-Danish characters return null
    try std.testing.expectEqual(@as(?[]const u8, null), mapDanishCodepoint('a')); // Regular ASCII
    try std.testing.expectEqual(@as(?[]const u8, null), mapDanishCodepoint(0x00C4)); // Ä (Swedish/Finnish)
}

test "finnish mappings" {
    // Test all Finnish-specific characters
    try std.testing.expectEqualStrings("A", mapFinnishCodepoint(0x00C4).?); // Ä
    try std.testing.expectEqualStrings("a", mapFinnishCodepoint(0x00E4).?); // ä
    try std.testing.expectEqualStrings("O", mapFinnishCodepoint(0x00D6).?); // Ö
    try std.testing.expectEqualStrings("o", mapFinnishCodepoint(0x00F6).?); // ö
    
    // Test that non-Finnish characters return null
    try std.testing.expectEqual(@as(?[]const u8, null), mapFinnishCodepoint('a')); // Regular ASCII
    try std.testing.expectEqual(@as(?[]const u8, null), mapFinnishCodepoint(0x00C5)); // Å (Swedish/Norwegian/Danish)
}
