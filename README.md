# slugifier

<p align="center">

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Zig](https://img.shields.io/badge/zig-0.13-orange.svg)](https://ziglang.org/)

</p>

slugifier is a fast and simple slug generation library written in Zig. It converts text into URL-friendly slugs with clean, reliable performance and straightforward configuration options.

Currently, the library provides solid basic slug generation with customizable separators, case formatting, and text normalization. While it handles ASCII text excellently, we're actively developing comprehensive Unicode support, language-specific transliteration, and advanced features that will make this the fastest and most feature-complete slug library available.

This project includes both a command-line tool and a library. The CLI provides instant slug generation for quick tasks and automation scripts. The library offers programmatic access with configurable options for separators, case formatting, and basic text processing.

**🚧 Coming Soon:**
- Full Unicode support with transliteration
- 50+ language-specific character mappings
- Zero-allocation performance modes
- Advanced SEO optimization features
- Compile-time slug generation
- C FFI and bindings for other languages

The library is built in Zig for optimal performance and memory safety, with a clean API that's easy to integrate into any project. See our [roadmap](docs/roadmap.md) for detailed information about upcoming features and development timeline.

## Install

### Command-Line Tool
Install the binary globally using Zig:

```bash
# Clone and build
git clone https://github.com/theiskaa/slugifier.git
cd slugifier
zig build -Doptimize=ReleaseFast
```

### As a Zig Library
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

### Command-Line Usage
The slugifier tool accepts text input and generates URL-friendly slugs with extensive customization options. It supports direct string input, file processing, and pipeline integration for automation workflows.

**Basic slug generation:**
```bash
slugifier "Hello, World!"
# Output: hello-world
```

**Custom separator and formatting:**
```bash
slugifier -s _ --format uppercase "Hello World"
# Output: HELLO_WORLD
```

**Advanced options:**
```bash
slugifier -s . -f default "My Project v2.0"
# Output: My.Project.v2.0
```

**Pipeline usage:**
```bash
echo "Convert this text" | slugifier --stdin
# Output: convert-this-text
```
