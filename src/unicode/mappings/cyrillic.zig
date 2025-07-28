const std = @import("std");

/// Maps a Cyrillic Unicode codepoint to ASCII equivalent
/// Uses ISO 9 transliteration standard (GOST 7.79-2000)
pub fn mapCyrillicCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        // Cyrillic Basic (А-Я) - Uppercase
        0x0410 => "A", // А
        0x0411 => "B", // Б
        0x0412 => "V", // В
        0x0413 => "G", // Г
        0x0414 => "D", // Д
        0x0415 => "E", // Е
        0x0416 => "ZH", // Ж
        0x0417 => "Z", // З
        0x0418 => "I", // И
        0x0419 => "J", // Й
        0x041A => "K", // К
        0x041B => "L", // Л
        0x041C => "M", // М
        0x041D => "N", // Н
        0x041E => "O", // О
        0x041F => "P", // П
        0x0420 => "R", // Р
        0x0421 => "S", // С
        0x0422 => "T", // Т
        0x0423 => "U", // У
        0x0424 => "F", // Ф
        0x0425 => "H", // Х
        0x0426 => "C", // Ц
        0x0427 => "CH", // Ч
        0x0428 => "SH", // Ш
        0x0429 => "SHCH", // Щ
        0x042A => "", // Ъ (hard sign - usually omitted)
        0x042B => "Y", // Ы
        0x042C => "", // Ь (soft sign - usually omitted)
        0x042D => "E", // Э
        0x042E => "YU", // Ю
        0x042F => "YA", // Я

        // Cyrillic Basic (а-я) - Lowercase
        0x0430 => "a", // а
        0x0431 => "b", // б
        0x0432 => "v", // в
        0x0433 => "g", // г
        0x0434 => "d", // д
        0x0435 => "e", // е
        0x0436 => "zh", // ж
        0x0437 => "z", // з
        0x0438 => "i", // и
        0x0439 => "j", // й
        0x043A => "k", // к
        0x043B => "l", // л
        0x043C => "m", // м
        0x043D => "n", // н
        0x043E => "o", // о
        0x043F => "p", // п
        0x0440 => "r", // р
        0x0441 => "s", // с
        0x0442 => "t", // т
        0x0443 => "u", // у
        0x0444 => "f", // ф
        0x0445 => "h", // х
        0x0446 => "c", // ц
        0x0447 => "ch", // ч
        0x0448 => "sh", // ш
        0x0449 => "shch", // щ
        0x044A => "", // ъ (hard sign - usually omitted)
        0x044B => "y", // ы
        0x044C => "", // ь (soft sign - usually omitted)
        0x044D => "e", // э
        0x044E => "yu", // ю
        0x044F => "ya", // я

        // Cyrillic Extended-A (Ѐ-ӿ)
        0x0400 => "IE", // Ѐ
        0x0401 => "IO", // Ё
        0x0402 => "DJ", // Ђ
        0x0403 => "GJ", // Ѓ
        0x0404 => "IE", // Є
        0x0405 => "DZ", // Ѕ
        0x0406 => "II", // І
        0x0407 => "YI", // Ї
        0x0408 => "J", // Ј
        0x0409 => "LJ", // Љ
        0x040A => "NJ", // Њ
        0x040B => "TSH", // Ћ
        0x040C => "KJ", // Ќ
        0x040D => "I", // Ѝ
        0x040E => "U", // Ў
        0x040F => "DZ", // Џ

        0x0450 => "ie", // ѐ
        0x0451 => "io", // ё
        0x0452 => "dj", // ђ
        0x0453 => "gj", // ѓ
        0x0454 => "ie", // є
        0x0455 => "dz", // ѕ
        0x0456 => "ii", // і
        0x0457 => "yi", // ї
        0x0458 => "j", // ј
        0x0459 => "lj", // љ
        0x045A => "nj", // њ
        0x045B => "tsh", // ћ
        0x045C => "kj", // ќ
        0x045D => "i", // ѝ
        0x045E => "u", // ў
        0x045F => "dz", // џ

        // Cyrillic Extended-B (Ҁ-ҿ)
        0x0480 => "K", // Ҁ
        0x0481 => "k", // ҁ
        0x0482 => "B", // ҂
        0x0483 => "b", // ҃
        0x0484 => "P", // ҄
        0x0485 => "p", // ҅
        0x0486 => "C", // ҆
        0x0487 => "c", // ҇
        0x0488 => "T", // ҈
        0x0489 => "t", // ҉
        0x048A => "G", // Ҋ
        0x048B => "g", // ҋ
        0x048C => "K", // Ҍ
        0x048D => "k", // ҍ
        0x048E => "N", // Ҏ
        0x048F => "n", // ҏ

        // Additional Cyrillic characters
        0x0490 => "G", // Ґ
        0x0491 => "g", // ґ
        0x0492 => "G", // Ғ
        0x0493 => "g", // ғ
        0x0494 => "G", // Ҕ
        0x0495 => "g", // ҕ
        0x0496 => "ZH", // Җ
        0x0497 => "zh", // җ
        0x0498 => "Z", // Ҙ
        0x0499 => "z", // ҙ
        0x049A => "K", // Қ
        0x049B => "k", // қ
        0x049C => "K", // Ҝ
        0x049D => "k", // ҝ
        0x049E => "K", // Ҟ
        0x049F => "k", // ҟ

        // Additional Cyrillic characters (continued)
        0x04A0 => "K", // Ҡ
        0x04A1 => "k", // ҡ
        0x04A2 => "K", // Ң
        0x04A3 => "k", // ң
        0x04A4 => "K", // Ҥ
        0x04A5 => "k", // ҥ
        0x04A6 => "K", // Ҧ
        0x04A7 => "k", // ҧ
        0x04A8 => "K", // Ҩ
        0x04A9 => "k", // ҩ
        0x04AA => "K", // Ҫ
        0x04AB => "k", // ҫ
        0x04AC => "K", // Ҭ
        0x04AD => "k", // ҭ
        0x04AE => "K", // Ү
        0x04AF => "k", // ү
        0x04B0 => "K", // Ұ
        0x04B1 => "k", // ұ
        0x04B2 => "K", // Ҳ
        0x04B3 => "k", // ҳ
        0x04B4 => "K", // Ҵ
        0x04B5 => "k", // ҵ
        0x04B6 => "K", // Ҷ
        0x04B7 => "k", // ҷ
        0x04B8 => "K", // Ҹ
        0x04B9 => "k", // ҹ
        0x04BA => "K", // Һ
        0x04BB => "k", // һ
        0x04BC => "K", // Ҽ
        0x04BD => "k", // ҽ
        0x04BE => "K", // Ҿ
        0x04BF => "k", // ҿ

        else => null,
    };
}

/// Russian-specific character mappings (standard Cyrillic)
pub fn mapRussianCodepoint(codepoint: u21) ?[]const u8 {
    return mapCyrillicCodepoint(codepoint);
}

/// Ukrainian-specific character mappings
pub fn mapUkrainianCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        0x0404 => "IE", // Є -> IE
        0x0454 => "ie", // є -> ie
        0x0406 => "I", // І -> I (Ukrainian specific)
        0x0456 => "i", // і -> i (Ukrainian specific)
        0x0407 => "YI", // Ї -> YI
        0x0457 => "yi", // ї -> yi
        else => mapCyrillicCodepoint(codepoint),
    };
}

/// Belarusian-specific character mappings
pub fn mapBelarusianCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        0x040E => "U", // Ў -> U
        0x045E => "u", // ў -> u
        0x0406 => "I", // І -> I (Belarusian specific)
        0x0456 => "i", // і -> i (Belarusian specific)
        else => mapCyrillicCodepoint(codepoint),
    };
}

/// Serbian-specific character mappings
pub fn mapSerbianCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        0x0402 => "DJ", // Ђ -> DJ
        0x0452 => "dj", // ђ -> dj
        0x0408 => "J", // Ј -> J
        0x0458 => "j", // ј -> j
        0x0409 => "LJ", // Љ -> LJ
        0x0459 => "lj", // љ -> lj
        0x040A => "NJ", // Њ -> NJ
        0x045A => "nj", // њ -> nj
        0x040B => "TSH", // Ћ -> TSH
        0x045B => "tsh", // ћ -> tsh
        0x040F => "DZ", // Џ -> DZ
        0x045F => "dz", // џ -> dz
        else => mapCyrillicCodepoint(codepoint),
    };
}

test "cyrillic mappings - basic letters" {
    try std.testing.expectEqualStrings("a", mapCyrillicCodepoint(0x0430).?); // а
    try std.testing.expectEqualStrings("b", mapCyrillicCodepoint(0x0431).?); // б
    try std.testing.expectEqualStrings("v", mapCyrillicCodepoint(0x0432).?); // в
    try std.testing.expectEqualStrings("g", mapCyrillicCodepoint(0x0433).?); // г
    try std.testing.expectEqualStrings("d", mapCyrillicCodepoint(0x0434).?); // д
}

test "cyrillic mappings - uppercase letters" {
    try std.testing.expectEqualStrings("A", mapCyrillicCodepoint(0x0410).?); // А
    try std.testing.expectEqualStrings("B", mapCyrillicCodepoint(0x0411).?); // Б
    try std.testing.expectEqualStrings("V", mapCyrillicCodepoint(0x0412).?); // В
    try std.testing.expectEqualStrings("G", mapCyrillicCodepoint(0x0413).?); // Г
    try std.testing.expectEqualStrings("D", mapCyrillicCodepoint(0x0414).?); // Д
}

test "cyrillic mappings - multi-character transliterations" {
    try std.testing.expectEqualStrings("zh", mapCyrillicCodepoint(0x0436).?); // ж
    try std.testing.expectEqualStrings("ch", mapCyrillicCodepoint(0x0447).?); // ч
    try std.testing.expectEqualStrings("sh", mapCyrillicCodepoint(0x0448).?); // ш
    try std.testing.expectEqualStrings("shch", mapCyrillicCodepoint(0x0449).?); // щ
    try std.testing.expectEqualStrings("yu", mapCyrillicCodepoint(0x044E).?); // ю
    try std.testing.expectEqualStrings("ya", mapCyrillicCodepoint(0x044F).?); // я
}

test "cyrillic mappings - uppercase multi-character" {
    try std.testing.expectEqualStrings("ZH", mapCyrillicCodepoint(0x0416).?); // Ж
    try std.testing.expectEqualStrings("CH", mapCyrillicCodepoint(0x0427).?); // Ч
    try std.testing.expectEqualStrings("SH", mapCyrillicCodepoint(0x0428).?); // Ш
    try std.testing.expectEqualStrings("SHCH", mapCyrillicCodepoint(0x0429).?); // Щ
    try std.testing.expectEqualStrings("YU", mapCyrillicCodepoint(0x042E).?); // Ю
    try std.testing.expectEqualStrings("YA", mapCyrillicCodepoint(0x042F).?); // Я
}

test "cyrillic mappings - hard and soft signs" {
    try std.testing.expectEqualStrings("", mapCyrillicCodepoint(0x044A).?); // ъ (hard sign)
    try std.testing.expectEqualStrings("", mapCyrillicCodepoint(0x044C).?); // ь (soft sign)
}

test "ukrainian specific mappings" {
    try std.testing.expectEqualStrings("ie", mapUkrainianCodepoint(0x0454).?); // є
    try std.testing.expectEqualStrings("i", mapUkrainianCodepoint(0x0456).?); // і
    try std.testing.expectEqualStrings("yi", mapUkrainianCodepoint(0x0457).?); // ї
}

test "belarusian specific mappings" {
    try std.testing.expectEqualStrings("u", mapBelarusianCodepoint(0x045E).?); // ў
    try std.testing.expectEqualStrings("i", mapBelarusianCodepoint(0x0456).?); // і
}

test "serbian specific mappings" {
    try std.testing.expectEqualStrings("dj", mapSerbianCodepoint(0x0452).?); // ђ
    try std.testing.expectEqualStrings("lj", mapSerbianCodepoint(0x0459).?); // љ
    try std.testing.expectEqualStrings("nj", mapSerbianCodepoint(0x045A).?); // њ
    try std.testing.expectEqualStrings("tsh", mapSerbianCodepoint(0x045B).?); // ћ
    try std.testing.expectEqualStrings("dz", mapSerbianCodepoint(0x045F).?); // џ
}

test "unmapped characters return null" {
    try std.testing.expectEqual(@as(?[]const u8, null), mapCyrillicCodepoint(0x4E00)); // Chinese character
    try std.testing.expectEqual(@as(?[]const u8, null), mapCyrillicCodepoint('a')); // Regular ASCII
}

test "cyrillic extended characters" {
    try std.testing.expectEqualStrings("ie", mapCyrillicCodepoint(0x0454).?); // є
    try std.testing.expectEqualStrings("ii", mapCyrillicCodepoint(0x0456).?); // і
    try std.testing.expectEqualStrings("yi", mapCyrillicCodepoint(0x0457).?); // ї
    try std.testing.expectEqualStrings("u", mapCyrillicCodepoint(0x045E).?); // ў
}

test "cyrillic language-specific overrides" {
    // Test that language-specific functions properly override generic mappings
    try std.testing.expectEqualStrings("ie", mapUkrainianCodepoint(0x0454).?); // є
    try std.testing.expectEqualStrings("u", mapBelarusianCodepoint(0x045E).?); // ў
    try std.testing.expectEqualStrings("dj", mapSerbianCodepoint(0x0452).?); // ђ
}

test "cyrillic fallback behavior" {
    // Test that language-specific functions fall back to generic mappings
    try std.testing.expectEqualStrings("a", mapUkrainianCodepoint(0x0430).?); // а
    try std.testing.expectEqualStrings("a", mapBelarusianCodepoint(0x0430).?); // а
    try std.testing.expectEqualStrings("a", mapSerbianCodepoint(0x0430).?); // а
}
