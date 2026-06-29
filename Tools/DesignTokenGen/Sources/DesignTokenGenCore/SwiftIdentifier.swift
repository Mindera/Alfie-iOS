import Foundation

/// Converts hyphenated DTCG token names into safe, deterministic Swift identifiers.
/// Figma names ship verbatim (`colours-neutrals-800`, `display-large`, `spacing-spacing-0`):
/// hyphen segments → lowerCamelCase, leading-digit segments stay glued to the previous word,
/// and Swift keywords are back-tick escaped.
public enum SwiftIdentifier {
    /// `colours-neutrals-800` → `coloursNeutrals800`; `body-x-small` → `bodyXSmall`.
    /// An optional `dropPrefix` strips a redundant category segment (e.g. `colours`).
    public static func make(_ dtcgName: String, dropPrefix: String? = nil) -> String {
        var segments = dtcgName.split(separator: "-").map(String.init)
        if let drop = dropPrefix, segments.first == drop {
            segments.removeFirst()
        }
        guard !segments.isEmpty else { return "_" }

        var result = ""
        for (index, segment) in segments.enumerated() {
            if index == 0 {
                result += lowerFirst(segment)
            } else if segment.first?.isNumber == true {
                // Numeric segment glues to the previous word: ...neutrals + 800 → neutrals800.
                result += segment
            } else {
                result += upperFirst(segment)
            }
        }
        if result.first?.isNumber == true { result = "_" + result }
        return escapeIfKeyword(result)
    }

    /// Asserts no two distinct DTCG names collapse to the same Swift identifier within a namespace.
    public static func assertNoCollisions(
        _ names: [String],
        dropPrefix: String? = nil
    ) throws {
        var byIdentifier: [String: [String]] = [:]
        for name in names {
            byIdentifier[make(name, dropPrefix: dropPrefix), default: []].append(name)
        }
        if let (swift, clashing) = byIdentifier.first(where: { $0.value.count > 1 }) {
            throw DesignTokenError.identifierCollision(swift: swift, names: clashing.sorted())
        }
    }

    private static func lowerFirst(_ s: String) -> String {
        guard let first = s.first else { return s }
        return first.lowercased() + s.dropFirst()
    }

    private static func upperFirst(_ s: String) -> String {
        guard let first = s.first else { return s }
        return first.uppercased() + s.dropFirst()
    }

    private static func escapeIfKeyword(_ identifier: String) -> String {
        keywords.contains(identifier) ? "`\(identifier)`" : identifier
    }

    private static let keywords: Set<String> = [
        "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func",
        "import", "init", "inout", "internal", "let", "open", "operator", "private",
        "protocol", "public", "rethrows", "static", "struct", "subscript", "typealias",
        "var", "break", "case", "continue", "default", "defer", "do", "else", "fallthrough",
        "for", "guard", "if", "in", "repeat", "return", "switch", "where", "while", "as",
        "catch", "false", "is", "nil", "self", "super", "throw", "throws", "true", "try",
        "Any", "Protocol", "Type",
        // Contextual keywords (concurrency / ownership / macros). Usable as identifiers in most
        // positions, but back-ticking is always valid and honors the keyword-escape contract.
        "actor", "async", "await", "some", "any", "macro", "package",
        "consuming", "borrowing", "isolated", "nonisolated", "distributed", "each", "sending",
    ]
}
