import Foundation

/// Turns a list of Handles into a directory of print-ready PNGs.
///
/// Everything is rendered before anything is written, so a bad line halfway down the list leaves no
/// half-finished print run behind.
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
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
            for item in rendered {
                try item.png.write(to: item.file)
            }
        } catch {
            throw AlfieCodeError.unwritableOutput(
                path: outputDirectory.path,
                reason: error.localizedDescription
            )
        }

        return Result(codes: rendered.map { .init(file: $0.file, link: $0.link) })
    }
}
