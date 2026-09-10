import AlfieCodeGenCore
import Foundation

let usage = """
usage: AlfieCodeGen <handles.txt> <output-dir>

The handle list is one Product handle per line, with an optional SKU after a comma:

    # Demo products
    mens-jeans-slim-indigo
    womens-coat-wool-camel, SKU-8842

Both arguments are required. Every code prints 30mm square at 100% scale, carrying a link to
https://localhost:4000 — the host the app already accepts.

"""

func fail(_ message: String, code: Int32) -> Never {
    FileHandle.standardError.write(Data("\(message)\n".utf8))
    exit(code)
}

// Positional and exact: an unrecognised argument is a typo, and a typo that prints a sheet of
// wrong-sized codes is exactly the quiet wrong answer this tool exists to avoid.
let arguments = CommandLine.arguments.dropFirst()
guard arguments.count == 2, let input = arguments.first, let output = arguments.last else {
    fail(usage, code: 2)
}

let size = PrintSize.swingTag

do {
    let result = try Generator.run(
        inputFile: URL(fileURLWithPath: input),
        outputDirectory: URL(fileURLWithPath: output, isDirectory: true),
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
