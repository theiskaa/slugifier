# slugifier

<p align="center">

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Zig](https://img.shields.io/badge/zig-0.13-orange.svg)](https://ziglang.org/)

</p>

slugifier is a fast and comprehensive slug generation library for Zig that converts text into URL-friendly slugs with exceptional performance and extensive Unicode support. The library provides robust text processing with customizable separators, case formatting, and advanced transliteration capabilities across multiple writing systems.

The core functionality centers around converting any text input into clean, web-safe slugs. The library handles ASCII text with optimal performance while providing comprehensive Unicode support through an advanced transliteration engine. This engine supports over 20 languages across multiple script families including Latin, Cyrillic, CJK (Chinese, Japanese, Korean), and RTL scripts (Arabic, Hebrew, Persian). The transliteration system is culturally aware, applying language-specific conversion rules that preserve linguistic accuracy rather than generic character mappings.

The library offers three Unicode processing modes to suit different requirements. Strip mode removes Unicode characters entirely for ASCII-only output. Preserve mode maintains Unicode characters as-is for international slug generation. Transliterate mode converts Unicode characters to ASCII equivalents using sophisticated language-specific mappings that understand cultural context. For example, German ü becomes "ue" rather than "u", while Swedish treats the same character as "u" according to local conventions.

The project provides both a command-line tool for quick slug generation and automation scripts, plus a library interface for programmatic integration. The CLI delivers instant results for one-off conversions and batch processing. The library API offers extensive configuration through struct options supporting custom separators, case formatting modes, language selection, and Unicode processing preferences. All operations maintain memory safety and provide error handling for invalid configurations.

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
The library exposes a main `slugify()` function that accepts raw text and configuration options through a `SlugifyOptions` struct. The function handles all text processing internally including Unicode detection, script classification, language-specific transliteration, case conversion, and separator normalization. The implementation leverages a sophisticated transliteration engine that maps Unicode characters to appropriate ASCII equivalents based on linguistic and cultural context.

The `slugify()` function returns an allocated string that the caller must manage. Memory allocation follows Zig conventions with explicit allocator passing for predictable memory management. The function performs comprehensive input validation and provides meaningful error codes for invalid configurations.

Configuration options include separator character selection (any non-alphanumeric ASCII character), case formatting (lowercase, uppercase, or preserve original), Unicode processing mode (strip, preserve, or transliterate), and optional language specification for culturally accurate transliteration. When a language is specified, the transliterator applies language-specific character mappings while falling back to generic mappings for characters outside that language's scope.

Import the library:
```zig
const slugifier = @import("slugifier");
```
Basic usage with default options:
```zig
const result = try slugifier.slugify("Hello, World!", .{}, allocator);
defer allocator.free(result); // Result: "hello-world"
```
Advanced configuration with language-specific transliteration:
```zig
const options = slugifier.SlugifyOptions{
    .separator = '_',
    .format = .uppercase,
    .unicode_mode = .transliterate,
    .language = .de, // German language mappings
};

const german_result = try slugifier.slugify("Müllerstraße", options, allocator);
defer allocator.free(german_result); // Result: "MUELLERSTRASSE"
```

Mixed script handling
```zig
const mixed_result = try slugifier.slugify("Hello 你好 Привет", .{}, allocator);
defer allocator.free(mixed_result); // Result: "hello-nihao-privet"
```

The library automatically detects and processes multiple Unicode scripts within the same input. When language-specific settings are configured, the transliterator prioritizes those mappings while falling back to generic script mappings for characters outside the specified language. This approach ensures comprehensive text processing regardless of input complexity.

## Unicode Support

The slugifier library provides comprehensive Unicode support through an advanced transliteration engine that handles multiple writing systems with cultural accuracy. The system currently supports over 20 languages across four major script families: Latin, Cyrillic, CJK (Chinese, Japanese, Korean), and RTL scripts (Arabic, Hebrew, Persian).

Supported languages include European languages (German, French, Spanish, Italian, Portuguese, Dutch), Slavic languages (Russian, Ukrainian, Polish, Czech, Belarusian, Serbian), Nordic languages (Swedish, Norwegian, Danish, Finnish), East Asian languages (Chinese Simplified/Traditional, Japanese, Korean), and Middle Eastern languages (Arabic, Hebrew, Persian/Farsi). Each language implementation follows proper transliteration standards and cultural conventions rather than generic character substitution.

The transliteration system operates through a hierarchical mapping approach. When a language is specified, the engine first attempts language-specific character mappings, then falls back to generic script mappings, ensuring comprehensive coverage for mixed-language content. For example, German-specific mappings handle ü as "ue" and ß as "ss", while generic Latin mappings provide broader coverage for other accented characters.

The Unicode processing pipeline includes automatic script detection, codepoint classification, and context-aware transliteration. The system can process text containing multiple scripts simultaneously, applying appropriate conversion rules for each script type. This approach enables accurate slug generation for international content while maintaining performance and reliability.

The transliteration mappings are modular and extensible. Adding support for new languages requires creating mapping functions in the `src/unicode/mappings/` directory that accept Unicode codepoints and return ASCII string replacements. The system automatically integrates new mappings into the fallback hierarchy without requiring changes to the core transliteration logic.

## Configuration

The slugifier library provides extensive customization through the `SlugifyOptions` struct with four primary configuration categories: separator selection, case formatting, Unicode processing mode, and language specification.

The separator option accepts any non-alphanumeric ASCII character to join words in the generated slug. Common choices include hyphens, underscores, dots, and plus signs. The library validates separator characters at runtime, rejecting alphanumeric characters that would conflict with slug content.

Case formatting operates through three modes: lowercase converts all output to lowercase for standard web URLs, uppercase converts all output to uppercase for specific branding requirements, and default preserves the original character casing for mixed-case applications. Case formatting applies after Unicode transliteration, ensuring consistent output regardless of input script.

Unicode processing mode determines how non-ASCII characters are handled. Strip mode removes Unicode characters entirely, producing ASCII-only output suitable for legacy systems. Preserve mode maintains Unicode characters unchanged, enabling international slugs for modern applications. Transliterate mode converts Unicode characters to ASCII equivalents using sophisticated language-aware mappings, balancing accessibility with linguistic accuracy.

Language specification enables culturally accurate transliteration by applying language-specific character mappings. When specified, the system prioritizes language mappings while maintaining fallback support for characters outside that language scope. This approach ensures optimal results for primary content language while handling multilingual input gracefully.

The configuration system includes comprehensive validation with meaningful error messages. Invalid separator characters, conflicting options, or malformed configurations are detected before processing begins, preventing runtime failures and ensuring predictable behavior across all usage scenarios.

## Contributing
For information regarding contributions, please refer to [CONTRIBUTING.md](CONTRIBUTING.md) file.
