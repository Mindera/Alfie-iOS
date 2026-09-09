import Foundation

/// Reads the plain-text list a solutions engineer keeps next to their demo notes:
///
/// ```
/// # Demo products
/// mens-jeans-slim-indigo
/// womens-coat-wool-camel, SKU-8842
/// mens/jeans/slim-indigo
/// ```
///
/// One Product per line, an optional SKU after a comma, `#` comments and blank lines ignored.
/// Anything else is rejected with the line number, because a typo'd Handle prints a code that
/// silently fails in the meeting room.
public enum HandleList {
    public static func parse(_ text: String) throws -> [AlfieCode] {
        var codes: [AlfieCode] = []
        var seenFileNames: Set<String> = []

        for (index, rawLine) in text.components(separatedBy: .newlines).enumerated() {
            let number = index + 1
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty, !line.hasPrefix("#") else { continue }

            let code = try parseEntry(line, number: number)
            guard seenFileNames.insert(code.fileName).inserted else {
                throw AlfieCodeError.duplicateEntry(fileName: code.fileName)
            }
            codes.append(code)
        }

        guard !codes.isEmpty else { throw AlfieCodeError.emptyList }
        return codes
    }

    // MARK: - One line

    /// The parser owns line numbers; `AlfieCode` owns what makes a code printable.
    private static func parseEntry(_ line: String, number: Int) throws -> AlfieCode {
        let fields = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard fields.count <= 2 else {
            throw AlfieCodeError.malformedLine(
                number: number,
                line: line,
                reason: "it has \(fields.count) comma-separated fields"
            )
        }

        let code = AlfieCode(handle: fields[0], sku: fields.count == 2 ? fields[1] : nil)
        if let problem = code.problem {
            throw AlfieCodeError.malformedLine(number: number, line: line, reason: problem)
        }
        return code
    }
}
