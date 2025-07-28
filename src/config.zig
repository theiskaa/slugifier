const std = @import("std");

/// Text case format options for slug generation.
pub const SlugifyFormat = enum {
    /// Convert all characters to lowercase
    lowercase,
    /// Convert all characters to uppercase
    uppercase,
    /// Keep original character casing
    default,
};

/// Unicode handling options for slug generation.
pub const TransliterationMode = enum {
    /// Remove Unicode characters completely (original behavior)
    strip,
    /// Keep Unicode characters as-is
    preserve,
    /// Convert Unicode to ASCII equivalents
    transliterate,
};

pub const Language = enum {
    de, // German
    fr, // French
    es, // Spanish
    ru, // Russian
    uk, // Ukrainian
    it, // Italian
    pt, // Portuguese
    nl, // Dutch
    pl, // Polish
    cz, // Czech
    be, // Belarusian
    sr, // Serbian
    sv, // Swedish
    no, // Norwegian
    da, // Danish
    fi, // Finnish
};

/// Configuration options for slug generation.
pub const SlugifyOptions = struct {
    /// Character to use as separator between words (default: '-')
    separator: u8 = '-',
    /// Text case format to apply (default: lowercase)
    format: SlugifyFormat = .lowercase,
    /// Unicode handling mode (default: transliterate)
    unicode_mode: TransliterationMode = .transliterate,
    /// Language to use for transliteration (default: null)
    language: ?Language = null,

    pub fn validate(self: SlugifyOptions) !void {
        // Ensure separator is valid ASCII character and not alphanumeric
        if (self.separator > 127) return error.InvalidSeparator;
        if (std.ascii.isAlphanumeric(self.separator)) {
            return error.SeparatorCannotBeAlphanumeric;
        }
    }
};

test "config validation - valid options" {
    const options = SlugifyOptions{};
    try options.validate();
}

test "config validation - custom separator" {
    const options = SlugifyOptions{ .separator = '_' };
    try options.validate();
}

test "config validation - invalid alphanumeric separator" {
    const options = SlugifyOptions{ .separator = 'a' };
    try std.testing.expectError(error.SeparatorCannotBeAlphanumeric, options.validate());
}
