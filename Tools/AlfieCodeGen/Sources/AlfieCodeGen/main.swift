import AlfieCodeGenCore
import Foundation

// Usage: AlfieCodeGen --input <handles.txt> --output <dir> [--base-url <url>] [--size-mm <n>] [--dpi <n>]
let usage = """
usage: AlfieCodeGen --input <handles.txt> --output <dir>
                    [--base-url https://localhost:4000] [--size-mm 30] [--dpi 300]

The handle list is one Product handle per line, with an optional SKU after a comma:

    # Demo products
    mens-jeans-slim-indigo
    womens-coat-wool-camel, SKU-8842

--size-mm is the exact printed width of each code; --dpi is the resolution floor.

"""

func value(for flag: String) -> String? {
    guard let i = CommandLine.arguments.firstIndex(of: flag), i + 1 < CommandLine.arguments.count else { return nil }
    return CommandLine.arguments[i + 1]
}

func fail(_ message: String, code: Int32) -> Never {
    FileHandle.standardError.write(Data("\(message)\n".utf8))
    exit(code)
}

/// A mistyped number must stop the run: silently printing a default-sized sheet is exactly the
/// kind of quiet wrong answer this tool exists to avoid.
func positiveNumber(for flag: String, default defaultValue: Double) -> Double {
    guard let raw = value(for: flag) else { return defaultValue }
    guard let number = Double(raw), number > 0 else {
        fail("❌ \(flag) needs a positive number, not \"\(raw)\".\n\n\(usage)", code: 2)
    }
    return number
}

guard let input = value(for: "--input"), let output = value(for: "--output") else {
    fail(usage, code: 2)
}

let baseURLArgument = value(for: "--base-url") ?? AlfieCode.defaultBaseURL.absoluteString
guard let baseURL = URL(string: baseURLArgument), baseURL.scheme == "https" else {
    // The spec fixes the payload as an https link; an http one scans but does not route.
    fail("❌ --base-url must be an https URL, not \"\(baseURLArgument)\".\n\n\(usage)", code: 2)
}

let size = PrintSize(
    millimetres: positiveNumber(for: "--size-mm", default: PrintSize.swingTag.millimetres),
    minimumDotsPerInch: positiveNumber(for: "--dpi", default: PrintSize.swingTag.minimumDotsPerInch)
)

do {
    let result = try Generator.run(
        inputFile: URL(fileURLWithPath: input),
        outputDirectory: URL(fileURLWithPath: output, isDirectory: true),
        baseURL: baseURL,
        size: size
    )
    for (file, link) in zip(result.files, result.links) {
        print("  \(file.lastPathComponent)  →  \(link.absoluteString)")
    }
    print(
        "✅ Wrote \(result.files.count) Alfie code(s) to \(output), "
            + "each printing \(Int(size.millimetres))mm square at 100% scale."
    )
} catch let error as AlfieCodeError {
    fail("❌ \(error.description)", code: 1)
} catch {
    fail("❌ \(error)", code: 1)
}
