const std = @import("std");

/// Maps a RTL Unicode codepoint to ASCII equivalent
pub fn mapRTLCodepoint(codepoint: u21) ?[]const u8 {
    // Try Hebrew first, then Arabic, then Persian
    if (mapHebrewCodepoint(codepoint)) |mapping| {
        return mapping;
    }
    if (mapArabicCodepoint(codepoint)) |mapping| {
        return mapping;
    }
    if (mapPersianCodepoint(codepoint)) |mapping| {
        return mapping;
    }
    return null;
}

/// Arabic-specific character mappings using standard transliteration
pub fn mapArabicCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        // Arabic letters
        0x0627 => "a", // ا - Alif
        0x0628 => "b", // ب - Ba
        0x062A => "t", // ت - Ta
        0x062B => "th", // ث - Tha
        0x062C => "j", // ج - Jim
        0x062D => "h", // ح - Ha (pharyngeal)
        0x062E => "kh", // خ - Kha
        0x062F => "d", // د - Dal
        0x0630 => "dh", // ذ - Dhal
        0x0631 => "r", // ر - Ra
        0x0632 => "z", // ز - Zay
        0x0633 => "s", // س - Sin
        0x0634 => "sh", // ش - Shin
        0x0635 => "s", // ص - Sad (emphatic)
        0x0636 => "d", // ض - Dad (emphatic)
        0x0637 => "t", // ط - Ta (emphatic)
        0x0638 => "z", // ظ - Za (emphatic)
        0x0639 => "'", // ع - Ayn
        0x063A => "gh", // غ - Ghayn
        0x0641 => "f", // ف - Fa
        0x0642 => "q", // ق - Qaf
        0x0643 => "k", // ك - Kaf
        0x0644 => "l", // ل - Lam
        0x0645 => "m", // م - Mim
        0x0646 => "n", // ن - Nun
        0x0647 => "h", // ه - Ha
        0x0648 => "w", // و - Waw
        0x064A => "y", // ي - Ya

        // Arabic short vowels (diacritics) - usually omitted in transliteration
        0x064B => "an", // ً - Fathatan
        0x064C => "un", // ٌ - Dammatan
        0x064D => "in", // ٍ - Kasratan
        0x064E => "a", // َ - Fatha
        0x064F => "u", // ُ - Damma
        0x0650 => "i", // ِ - Kasra
        0x0651 => "", // ّ - Shadda (doubling)
        0x0652 => "", // ْ - Sukun (no vowel)

        // Arabic-Indic digits
        0x0660 => "0", // ٠
        0x0661 => "1", // ١
        0x0662 => "2", // ٢
        0x0663 => "3", // ٣
        0x0664 => "4", // ٤
        0x0665 => "5", // ٥
        0x0666 => "6", // ٦
        0x0667 => "7", // ٧
        0x0668 => "8", // ٨
        0x0669 => "9", // ٩

        // Additional Arabic letters
        0x0621 => "'", // ء - Hamza
        0x0622 => "a", // آ - Alif with Madda above
        0x0623 => "a", // أ - Alif with Hamza above
        0x0624 => "u", // ؤ - Waw with Hamza above
        0x0625 => "i", // إ - Alif with Hamza below
        0x0626 => "y", // ئ - Ya with Hamza above
        0x0629 => "t", // ة - Ta Marbuta

        // Extended Arabic (for other languages using Arabic script)
        0x067E => "p", // پ - Pe (Persian/Urdu)
        0x0686 => "ch", // چ - Che (Persian/Urdu)
        0x0698 => "zh", // ژ - Zhe (Persian)
        0x06A9 => "k", // ک - Keheh (Persian)
        0x06AF => "g", // گ - Gaf (Persian/Urdu)
        0x06CC => "y", // ی - Farsi Yeh

        // Arabic punctuation
        0x060C => ",", // ، - Arabic comma
        0x061B => ";", // ؛ - Arabic semicolon
        0x061F => "?", // ؟ - Arabic question mark

        else => null,
    };
}

/// Hebrew-specific character mappings using standard transliteration
pub fn mapHebrewCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        // Hebrew letters
        0x05D0 => "a", // א - Alef
        0x05D1 => "b", // ב - Bet
        0x05D2 => "g", // ג - Gimel
        0x05D3 => "d", // ד - Dalet
        0x05D4 => "h", // ה - He
        0x05D5 => "v", // ו - Vav
        0x05D6 => "z", // ז - Zayin
        0x05D7 => "h", // ח - Het
        0x05D8 => "t", // ט - Tet
        0x05D9 => "y", // י - Yod
        0x05DA => "k", // ך - Kaf sofit (final)
        0x05DB => "k", // כ - Kaf
        0x05DC => "l", // ל - Lamed
        0x05DD => "m", // ם - Mem sofit (final)
        0x05DE => "m", // מ - Mem
        0x05DF => "n", // ן - Nun sofit (final)
        0x05E0 => "n", // נ - Nun
        0x05E1 => "s", // ס - Samekh
        0x05E2 => "'", // ע - Ayin
        0x05E3 => "p", // ף - Pe sofit (final)
        0x05E4 => "p", // פ - Pe
        0x05E5 => "ts", // ץ - Tsadi sofit (final)
        0x05E6 => "ts", // צ - Tsadi
        0x05E7 => "q", // ק - Qof
        0x05E8 => "r", // ר - Resh
        0x05E9 => "sh", // ש - Shin
        0x05EA => "t", // ת - Tav

        // Hebrew points (vowels) - usually omitted in transliteration
        0x05B0 => "e", // ְ - Sheva
        0x05B1 => "e", // ֱ - Hataf Segol
        0x05B2 => "a", // ֲ - Hataf Patah
        0x05B3 => "o", // ֳ - Hataf Qamats
        0x05B4 => "i", // ִ - Hiriq
        0x05B5 => "e", // ֵ - Tsere
        0x05B6 => "e", // ֶ - Segol
        0x05B7 => "a", // ַ - Patah
        0x05B8 => "a", // ָ - Qamats
        0x05B9 => "o", // ֹ - Holam
        0x05BA => "o", // ֺ - Holam Haser for Vav
        0x05BB => "u", // ֻ - Qubuts
        0x05BC => "", // ּ - Dagesh
        0x05BD => "", // ֽ - Meteg
        0x05BE => "-", // ־ - Maqaf (Hebrew hyphen)
        0x05BF => "", // ֿ - Rafe
        0x05C0 => "|", // ׀ - Paseq
        0x05C1 => "s", // ׁ - Shin Dot
        0x05C2 => "s", // ׂ - Sin Dot

        // Hebrew punctuation
        0x05F3 => "'", // ׳ - Geresh
        0x05F4 => "\"", // ״ - Gershayim

        else => null,
    };
}

/// Persian-specific character mappings using standard transliteration
pub fn mapPersianCodepoint(codepoint: u21) ?[]const u8 {
    return switch (codepoint) {
        // Persian uses Arabic script with additional letters
        // First check Persian-specific letters, then fall back to Arabic

        // Persian-specific letters
        0x067E => "p", // پ - Pe
        0x0686 => "ch", // چ - Che
        0x0698 => "zh", // ژ - Zhe
        0x06A9, 0x0643 => "k", // ک/ك - Keheh/Kaf
        0x06AF => "g", // گ - Gaf
        0x06CC => "i", // ی - Farsi Yeh (at end of word = i)

        // Persian numbers (different from Arabic-Indic)
        0x06F0 => "0", // ۰
        0x06F1 => "1", // ۱
        0x06F2 => "2", // ۲
        0x06F3 => "3", // ۳
        0x06F4 => "4", // ۴
        0x06F5 => "5", // ۵
        0x06F6 => "6", // ۶
        0x06F7 => "7", // ۷
        0x06F8 => "8", // ۸
        0x06F9 => "9", // ۹

        // Common Arabic letters in Persian context
        0x0627 => "a", // ا - Alif
        0x0628 => "b", // ب - Be
        0x062A => "t", // ت - Te
        0x062B => "s", // ث - Se (Persian pronunciation)
        0x062C => "j", // ج - Jim
        0x062D => "h", // ح - He jimi
        0x062E => "kh", // خ - Khe
        0x062F => "d", // د - Dal
        0x0630 => "z", // ذ - Zal (Persian pronunciation)
        0x0631 => "r", // ر - Re
        0x0632 => "z", // ز - Ze
        0x0633 => "s", // س - Sin
        0x0634 => "sh", // ش - Shin
        0x0635 => "s", // ص - Sad
        0x0636 => "z", // ض - Zad (Persian pronunciation)
        0x0637 => "t", // ط - Ta
        0x0638 => "z", // ظ - Za
        0x0639 => "'", // ع - Eyn
        0x063A => "gh", // غ - Gheyn
        0x0641 => "f", // ف - Fe
        0x0642 => "gh", // ق - Ghaf (Persian pronunciation)
        0x0644 => "l", // ل - Lam
        0x0645 => "m", // م - Mim
        0x0646 => "n", // ن - Nun
        0x0647 => "h", // ه - He
        0x0648 => "v", // و - Vav (Persian pronunciation)
        0x064A => "y", // ي - Ye

        // Persian-specific combined characters
        0x0622 => "a", // آ - Alif with Madda (aa sound)
        0x0629 => "h", // ة - Te marbute

        else => null,
    };
}

test "arabic mappings - basic letters" {
    try std.testing.expectEqualStrings("a", mapArabicCodepoint(0x0627).?); // ا
    try std.testing.expectEqualStrings("b", mapArabicCodepoint(0x0628).?); // ب
    try std.testing.expectEqualStrings("t", mapArabicCodepoint(0x062A).?); // ت
    try std.testing.expectEqualStrings("th", mapArabicCodepoint(0x062B).?); // ث
    try std.testing.expectEqualStrings("j", mapArabicCodepoint(0x062C).?); // ج
    try std.testing.expectEqualStrings("h", mapArabicCodepoint(0x062D).?); // ح
    try std.testing.expectEqualStrings("kh", mapArabicCodepoint(0x062E).?); // خ
    try std.testing.expectEqualStrings("d", mapArabicCodepoint(0x062F).?); // د
    try std.testing.expectEqualStrings("dh", mapArabicCodepoint(0x0630).?); // ذ
    try std.testing.expectEqualStrings("r", mapArabicCodepoint(0x0631).?); // ر
    try std.testing.expectEqualStrings("z", mapArabicCodepoint(0x0632).?); // ز
    try std.testing.expectEqualStrings("s", mapArabicCodepoint(0x0633).?); // س
    try std.testing.expectEqualStrings("sh", mapArabicCodepoint(0x0634).?); // ش
}

test "arabic mappings - more letters" {
    try std.testing.expectEqualStrings("f", mapArabicCodepoint(0x0641).?); // ف
    try std.testing.expectEqualStrings("q", mapArabicCodepoint(0x0642).?); // ق
    try std.testing.expectEqualStrings("k", mapArabicCodepoint(0x0643).?); // ك
    try std.testing.expectEqualStrings("l", mapArabicCodepoint(0x0644).?); // ل
    try std.testing.expectEqualStrings("m", mapArabicCodepoint(0x0645).?); // م
    try std.testing.expectEqualStrings("n", mapArabicCodepoint(0x0646).?); // ن
    try std.testing.expectEqualStrings("h", mapArabicCodepoint(0x0647).?); // ه
    try std.testing.expectEqualStrings("w", mapArabicCodepoint(0x0648).?); // و
    try std.testing.expectEqualStrings("y", mapArabicCodepoint(0x064A).?); // ي
}

test "arabic mappings - numbers" {
    try std.testing.expectEqualStrings("0", mapArabicCodepoint(0x0660).?); // ٠
    try std.testing.expectEqualStrings("1", mapArabicCodepoint(0x0661).?); // ١
    try std.testing.expectEqualStrings("2", mapArabicCodepoint(0x0662).?); // ٢
    try std.testing.expectEqualStrings("3", mapArabicCodepoint(0x0663).?); // ٣
    try std.testing.expectEqualStrings("4", mapArabicCodepoint(0x0664).?); // ٤
    try std.testing.expectEqualStrings("5", mapArabicCodepoint(0x0665).?); // ٥
    try std.testing.expectEqualStrings("9", mapArabicCodepoint(0x0669).?); // ٩
}

test "arabic mappings - punctuation" {
    try std.testing.expectEqualStrings(",", mapArabicCodepoint(0x060C).?); // ،
    try std.testing.expectEqualStrings(";", mapArabicCodepoint(0x061B).?); // ؛
    try std.testing.expectEqualStrings("?", mapArabicCodepoint(0x061F).?); // ؟
}

test "hebrew mappings - basic letters" {
    try std.testing.expectEqualStrings("a", mapHebrewCodepoint(0x05D0).?); // א
    try std.testing.expectEqualStrings("b", mapHebrewCodepoint(0x05D1).?); // ב
    try std.testing.expectEqualStrings("g", mapHebrewCodepoint(0x05D2).?); // ג
    try std.testing.expectEqualStrings("d", mapHebrewCodepoint(0x05D3).?); // ד
    try std.testing.expectEqualStrings("h", mapHebrewCodepoint(0x05D4).?); // ה
    try std.testing.expectEqualStrings("v", mapHebrewCodepoint(0x05D5).?); // ו
    try std.testing.expectEqualStrings("z", mapHebrewCodepoint(0x05D6).?); // ז
    try std.testing.expectEqualStrings("h", mapHebrewCodepoint(0x05D7).?); // ח
    try std.testing.expectEqualStrings("t", mapHebrewCodepoint(0x05D8).?); // ט
    try std.testing.expectEqualStrings("y", mapHebrewCodepoint(0x05D9).?); // י
}

test "hebrew mappings - more letters" {
    try std.testing.expectEqualStrings("k", mapHebrewCodepoint(0x05DB).?); // כ
    try std.testing.expectEqualStrings("k", mapHebrewCodepoint(0x05DA).?); // ך (final kaf)
    try std.testing.expectEqualStrings("l", mapHebrewCodepoint(0x05DC).?); // ל
    try std.testing.expectEqualStrings("m", mapHebrewCodepoint(0x05DE).?); // מ
    try std.testing.expectEqualStrings("m", mapHebrewCodepoint(0x05DD).?); // ם (final mem)
    try std.testing.expectEqualStrings("n", mapHebrewCodepoint(0x05E0).?); // נ
    try std.testing.expectEqualStrings("n", mapHebrewCodepoint(0x05DF).?); // ן (final nun)
    try std.testing.expectEqualStrings("s", mapHebrewCodepoint(0x05E1).?); // ס
    try std.testing.expectEqualStrings("p", mapHebrewCodepoint(0x05E4).?); // פ
    try std.testing.expectEqualStrings("ts", mapHebrewCodepoint(0x05E6).?); // צ
    try std.testing.expectEqualStrings("r", mapHebrewCodepoint(0x05E8).?); // ר
    try std.testing.expectEqualStrings("sh", mapHebrewCodepoint(0x05E9).?); // ש
    try std.testing.expectEqualStrings("t", mapHebrewCodepoint(0x05EA).?); // ת
}

test "hebrew mappings - vowels" {
    try std.testing.expectEqualStrings("a", mapHebrewCodepoint(0x05B7).?); // ַ - Patah
    try std.testing.expectEqualStrings("e", mapHebrewCodepoint(0x05B5).?); // ֵ - Tsere
    try std.testing.expectEqualStrings("i", mapHebrewCodepoint(0x05B4).?); // ִ - Hiriq
    try std.testing.expectEqualStrings("o", mapHebrewCodepoint(0x05B9).?); // ֹ - Holam
    try std.testing.expectEqualStrings("u", mapHebrewCodepoint(0x05BB).?); // ֻ - Qubuts
}

test "persian mappings - specific letters" {
    try std.testing.expectEqualStrings("p", mapPersianCodepoint(0x067E).?); // پ - Pe
    try std.testing.expectEqualStrings("ch", mapPersianCodepoint(0x0686).?); // چ - Che
    try std.testing.expectEqualStrings("zh", mapPersianCodepoint(0x0698).?); // ژ - Zhe
    try std.testing.expectEqualStrings("k", mapPersianCodepoint(0x06A9).?); // ک - Keheh
    try std.testing.expectEqualStrings("g", mapPersianCodepoint(0x06AF).?); // گ - Gaf
    try std.testing.expectEqualStrings("i", mapPersianCodepoint(0x06CC).?); // ی - Farsi Yeh
}

test "persian mappings - numbers" {
    try std.testing.expectEqualStrings("0", mapPersianCodepoint(0x06F0).?); // ۰
    try std.testing.expectEqualStrings("1", mapPersianCodepoint(0x06F1).?); // ۱
    try std.testing.expectEqualStrings("2", mapPersianCodepoint(0x06F2).?); // ۲
    try std.testing.expectEqualStrings("5", mapPersianCodepoint(0x06F5).?); // ۵
    try std.testing.expectEqualStrings("9", mapPersianCodepoint(0x06F9).?); // ۹
}

test "persian mappings - common arabic letters" {
    try std.testing.expectEqualStrings("a", mapPersianCodepoint(0x0627).?); // ا
    try std.testing.expectEqualStrings("b", mapPersianCodepoint(0x0628).?); // ب
    try std.testing.expectEqualStrings("s", mapPersianCodepoint(0x062B).?); // ث (Persian pronunciation)
    try std.testing.expectEqualStrings("z", mapPersianCodepoint(0x0630).?); // ذ (Persian pronunciation)
    try std.testing.expectEqualStrings("z", mapPersianCodepoint(0x0636).?); // ض (Persian pronunciation)
    try std.testing.expectEqualStrings("gh", mapPersianCodepoint(0x0642).?); // ق (Persian pronunciation)
    try std.testing.expectEqualStrings("v", mapPersianCodepoint(0x0648).?); // و (Persian pronunciation)
}

test "rtl mappings - generic fallback" {
    // Test that generic RTL mapping tries all three languages
    try std.testing.expectEqualStrings("a", mapRTLCodepoint(0x05D0).?); // Hebrew א
    try std.testing.expectEqualStrings("a", mapRTLCodepoint(0x0627).?); // Arabic ا
    try std.testing.expectEqualStrings("p", mapRTLCodepoint(0x067E).?); // Persian پ
}

test "rtl mappings - unmapped characters return null" {
    try std.testing.expectEqual(@as(?[]const u8, null), mapRTLCodepoint('a')); // Regular ASCII
    try std.testing.expectEqual(@as(?[]const u8, null), mapArabicCodepoint('a')); // Regular ASCII
    try std.testing.expectEqual(@as(?[]const u8, null), mapHebrewCodepoint('a')); // Regular ASCII  
    try std.testing.expectEqual(@as(?[]const u8, null), mapPersianCodepoint('a')); // Regular ASCII
    try std.testing.expectEqual(@as(?[]const u8, null), mapArabicCodepoint(0x4E00)); // Chinese character
    try std.testing.expectEqual(@as(?[]const u8, null), mapHebrewCodepoint(0x4E00)); // Chinese character
    try std.testing.expectEqual(@as(?[]const u8, null), mapPersianCodepoint(0x4E00)); // Chinese character
}