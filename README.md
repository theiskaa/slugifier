# slugifier

<p align="center">

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Zig](https://img.shields.io/badge/zig-0.13-orange.svg)](https://ziglang.org/)

</p>

slugifier is a fast and simple slug generation library for Zig. It converts text into URL-friendly slugs with clean, reliable performance and straightforward configuration options.

The library provides solid basic slug generation with customizable separators, case formatting, and text normalization. It handles ASCII text excellently and includes comprehensive Unicode support with transliteration capabilities. The project includes both a command-line tool and a library. The CLI provides instant slug generation for quick tasks and automation scripts. The library offers programmatic access with configurable options for separators, case formatting, and Unicode processing.

The library is fast and reliable,It handles comprehensive text processing including Unicode transliteration, case conversion, and separator normalization. Configuration is flexible through struct options that can be customized for different use cases. The library supports multiple Unicode handling modes and can generate slugs optimized for URLs, filenames, or database keys.

## Install

Install the binary globally using Zig:

```bash
git clone https://github.com/theiskaa/slugifier.git
cd slugifier
zig build -Doptimize=ReleaseFast
```

## Install as library

Add to your `build.zig.zon`:

```zig
.{
    .name = "your-project",
    .version = "0.1.0",
    .dependencies = .{
        .slugifier = .{
            .url = "https://github.com/theiskaa/slugifier/archive/main.tar.gz",
            .hash = "1234...", // zig will provide this
        },
    },
}
```

Or add to your project as a Git submodule:

```bash
git submodule add https://github.com/theiskaa/slugifier.git libs/slugifier
```

## Usage
The library exposes a main `slugify()` function that accepts raw text and configuration options. It handles all intermediate processing steps internally. The function leverages Unicode transliteration to convert accented characters to ASCII equivalents, applies case formatting, and normalizes separators.

The `slugify()` function returns an allocated string that the caller must free. The function uses a `SlugifyOptions` struct for configuration, supporting custom separators, case formatting, and Unicode handling modes.

The library uses a `TransliterationMode` enum to specify how Unicode characters should be processed. This supports three approaches: strip mode removes Unicode characters completely, preserve mode keeps Unicode as-is, and transliterate mode converts Unicode to ASCII equivalents.

```zig
const slugifier = @import("slugifier");

const options = slugifier.SlugifyOptions{
    .separator = '-',
    .format = .lowercase,
    .unicode_mode = .transliterate,
};

const result = try slugifier.slugify("Café naïve", options, allocator);
defer allocator.free(result);
// Result: "cafe-naive"
```

For advanced usage, you can work directly with the transliterator component. Create a transliterator instance with specific options, then call the `slugify()` method to process text. This approach provides fine-grained control over the Unicode processing pipeline.

## Unicode Support

The slugifier library includes comprehensive Unicode support through a transliteration engine. The engine maps Unicode characters to ASCII equivalents based on language-specific rules and cultural context.

The transliteration system is modular and extensible. New language mappings can be added by creating mapping functions in the `src/unicode/mappings/` directory. Each mapping function should accept a Unicode codepoint and return an optional ASCII string replacement.

To add support for a new language, create a new file in the mappings directory following the pattern of existing files. Define a mapping function that handles the specific Unicode characters for that language. The function should return null for unmapped characters, allowing fallback to generic mappings.

Language-specific mappings can override generic Latin mappings for cultural accuracy. For example, German mappings convert ü to "ue" instead of "u", while Swedish mappings keep ü as "u". These cultural differences are important for proper slug generation in different locales.

The transliterator automatically selects appropriate mappings based on the configured language option. When no specific language is set, it uses generic Latin mappings that work well for most European languages.

## Configuration

The slugifier library supports extensive customization through the `SlugifyOptions` struct. Configuration includes separator character selection, case formatting options, and Unicode processing modes.

The separator option controls the character used between words in the generated slug. Valid separators are any non-alphanumeric ASCII character. The format option controls text case conversion with three modes: lowercase converts all text to lowercase, uppercase converts all text to uppercase, and default preserves original casing.

The unicode_mode option controls Unicode character processing. Strip mode removes all Unicode characters, preserve mode keeps Unicode as-is, and transliterate mode converts Unicode to ASCII equivalents using language-specific mappings.

Error handling is graceful - if invalid options are provided, the library returns appropriate error codes rather than crashing. The validate() method on SlugifyOptions ensures configuration is correct before processing begins.

## Contributing
For information regarding contributions, please refer to [CONTRIBUTING.md](CONTRIBUTING.md) file.
