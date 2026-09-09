import Foundation

/// Turns a list of Handles into a directory of print-ready PNGs.
///
/// Everything is rendered before anything is written, so a bad line halfway down the list leaves no
/// half-finished print run behind.
public enum Generator {
    public struct Result: Equatable {
        /// The files written, in list order.
        public let files: [URL]
        /// The link encoded into each file, for the run summary.
        public let links: [URL]
    }

    public static func run(
        inputFile: URL,
        outputDirectory: URL,
        baseURL: URL,
        size: PrintSize
    ) throws -> Result {
        guard let text = try? String(contentsOf: inputFile, encoding: .utf8) else {
            throw AlfieCodeError.unreadableInput(path: inputFile.path)
        }
        return try run(list: text, outputDirectory: outputDirectory, baseURL: baseURL, size: size)
    }

    public static func run(
        list: String,
        outputDirectory: URL,
        baseURL: URL,
        size: PrintSize
    ) throws -> Result {
        let codes = try HandleList.parse(list)

        let rendered = try codes.map { code -> (file: URL, link: URL, png: Data) in
            let link = try code.url(baseURL: baseURL)
            return (
                file: outputDirectory.appendingPathComponent(code.fileName),
                link: link,
                png: try AlfieCodeImage.png(link: link, caption: code.caption, size: size)
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

        return Result(files: rendered.map(\.file), links: rendered.map(\.link))
    }
}
