const std = @import("std");
const slugifier = @import("root.zig");

const usage_text =
    \\Usage: slugifier [OPTIONS] <text>
    \\
    \\Convert text to URL-friendly slugs.
    \\
    \\OPTIONS:
    \\  -s, --separator <char>    Separator character (default: '-')
    \\  -f, --format <format>     Text format: lowercase, uppercase, default (default: lowercase)
    \\  -h, --help               Show this help message
    \\
    \\EXAMPLES:
    \\  slugifier "Hello, World!"
    \\  slugifier -s _ "Hello World"
    \\  slugifier --format uppercase "hello world"
    \\  slugifier -s . -f default "My Project v2.0"
    \\
;

const CliError = error{
    InvalidArguments,
    InvalidFormat,
    InvalidSeparator,
    MissingText,
};

const CliOptions = struct {
    text: [:0]const u8,
    separator: u8 = '-',
    format: slugifier.SlugifyFormat = .lowercase,
    max_length: ?usize = null,
};

fn printUsage() void {
    std.debug.print("{s}", .{usage_text});
}

fn parseFormat(format_str: [:0]const u8) !slugifier.SlugifyFormat {
    if (std.mem.eql(u8, format_str, "lowercase")) {
        return .lowercase;
    } else if (std.mem.eql(u8, format_str, "uppercase")) {
        return .uppercase;
    } else if (std.mem.eql(u8, format_str, "default")) {
        return .default;
    } else {
        return CliError.InvalidFormat;
    }
}

fn parseArgs(args: [][:0]u8) !CliOptions {
    var options = CliOptions{ .text = undefined };
    var i: usize = 1; // Skip program name
    var text_found = false;

    while (i < args.len) {
        const arg = args[i];

        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            printUsage();
            std.process.exit(0);
        } else if (std.mem.eql(u8, arg, "-s") or std.mem.eql(u8, arg, "--separator")) {
            if (i + 1 >= args.len) {
                std.debug.print("Error: --separator requires a value\n", .{});
                return CliError.InvalidArguments;
            }
            i += 1;
            const sep_str = args[i];
            if (sep_str.len != 1) {
                std.debug.print("Error: Separator must be a single character\n", .{});
                return CliError.InvalidSeparator;
            }
            options.separator = sep_str[0];
        } else if (std.mem.eql(u8, arg, "-f") or std.mem.eql(u8, arg, "--format")) {
            if (i + 1 >= args.len) {
                std.debug.print("Error: --format requires a value\n", .{});
                return CliError.InvalidArguments;
            }
            i += 1;
            options.format = parseFormat(args[i]) catch {
                std.debug.print("Error: Invalid format '{s}'. Valid formats: lowercase, uppercase, default\n", .{args[i]});
                return CliError.InvalidFormat;
            };
        } else if (!text_found) {
            options.text = arg;
            text_found = true;
        } else {
            std.debug.print("Error: Unexpected argument '{s}'\n", .{arg});
            return CliError.InvalidArguments;
        }

        i += 1;
    }

    if (!text_found) {
        std.debug.print("Error: Missing text to slugify\n", .{});
        return CliError.MissingText;
    }

    return options;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        printUsage();
        std.process.exit(1);
    }

    const cli_options = parseArgs(args) catch |err| {
        switch (err) {
            CliError.InvalidArguments, CliError.InvalidFormat, CliError.InvalidSeparator, CliError.MissingText => {
                std.debug.print("\nUse --help for usage information.\n", .{});
                std.process.exit(1);
            },
            else => return err,
        }
    };

    const slug_options = slugifier.SlugifyOptions{
        .max_length = cli_options.max_length,
        .separator = cli_options.separator,
        .format = cli_options.format,
    };

    const result = try slugifier.slugify(cli_options.text, slug_options, allocator);
    defer allocator.free(result);

    std.debug.print("{s}\n", .{result});
}
