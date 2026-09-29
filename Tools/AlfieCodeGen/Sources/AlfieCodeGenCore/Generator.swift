import Foundation

/// Turns a list of Handles into a directory of print-ready PNGs.
///
/// Everything is rendered before anything is written, so a bad line halfway down the list leaves no
/// half-finished print run behind. The destination then ends up holding exactly this run's codes: a
/// stale PNG from a longer earlier run prints just as well as a current one, and nothing on the
/// printed tag says which run it came from.
public enum Generator {
    /// The size every code is rendered at. There is one printed artefact — the swing tag — so this
    /// is a fact about the tool rather than a choice offered to its callers. Exposed so a caller can
    /// report it without having to pick it.
    public static let printSize: PrintSize = .swingTag

    public struct Result: Equatable {
        /// One written file and the link encoded into it. Kept together rather than returned as two
        /// arrays the caller has to zip back up, which only works while both stay in list order.
        public struct Code: Equatable {
            public let file: URL
            public let link: URL
        }

        /// The codes written, in list order.
        public let codes: [Code]
    }

    public static func run(inputFile: URL, outputDirectory: URL) throws -> Result {
        guard let text = try? String(contentsOf: inputFile, encoding: .utf8) else {
            throw AlfieCodeError.unreadableInput(path: inputFile.path)
        }
        return try run(list: text, outputDirectory: outputDirectory)
    }

    public static func run(list: String, outputDirectory: URL) throws -> Result {
        let codes = try HandleList.parse(list)

        let rendered = try codes.map { code -> (file: URL, link: URL, png: Data) in
            let link = try code.url()
            return (
                file: outputDirectory.appendingPathComponent(code.fileName),
                link: link,
                png: try AlfieCodeImage.png(link: link, caption: code.caption, size: printSize)
            )
        }

        do {
            try replaceContents(of: outputDirectory, with: rendered)
        } catch {
            throw AlfieCodeError.unwritableOutput(
                path: outputDirectory.path,
                reason: error.localizedDescription
            )
        }

        return Result(codes: rendered.map { .init(file: $0.file, link: $0.link) })
    }

    /// Writes the run into a sibling directory and swaps it in, so the destination is never a mixture
    /// of two runs — not mid-write, and not afterwards either.
    private static func replaceContents(
        of outputDirectory: URL,
        with rendered: [(file: URL, link: URL, png: Data)]
    ) throws {
        let fileManager = FileManager.default
        let parent = outputDirectory.deletingLastPathComponent()
        try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)

        // A sibling rather than the system temporary directory: `replaceItemAt` is only atomic within
        // one volume, and the caller chooses where the output lands.
        let staging = parent.appendingPathComponent(
            ".\(outputDirectory.lastPathComponent).\(UUID().uuidString)",
            isDirectory: true
        )
        try fileManager.createDirectory(at: staging, withIntermediateDirectories: false)
        defer { try? fileManager.removeItem(at: staging) }

        for item in rendered {
            try item.png.write(to: staging.appendingPathComponent(item.file.lastPathComponent))
        }

        if fileManager.fileExists(atPath: outputDirectory.path) {
            _ = try fileManager.replaceItemAt(outputDirectory, withItemAt: staging)
        } else {
            try fileManager.moveItem(at: staging, to: outputDirectory)
        }
    }
}
