import Foundation

extension String {
    public func trim() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func prefixIfNeeded(with prefix: String) -> String {
        guard !hasPrefix(prefix) else {
            return self
        }
        return prefix + self
    }

    public func deletingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else {
            return self
        }
        return String(self.dropFirst(prefix.count))
    }

    public var isBlank: Bool {
        trim().isEmpty
    }

    /// Strips HTML tags and decodes the most common entities, yielding plain text.
    /// Regex-based (not `NSAttributedString`) so it is deterministic and has no main-thread
    /// requirement — suitable for the BFF response converter.
    public func strippingHTML() -> String {
        // Turn block-level boundaries into spaces first, so adjacent blocks (e.g.
        // `<p>A</p><p>B</p>`) don't run together once the tags are removed.
        replacingOccurrences(
            of: "(?i)</(p|div|li|h[1-6]|tr|td)>|<br[^>]*>",
            with: " ",
            options: .regularExpression
        )
        .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        .replacingOccurrences(of: "&nbsp;", with: " ")
        .replacingOccurrences(of: "&lt;", with: "<")
        .replacingOccurrences(of: "&gt;", with: ">")
        .replacingOccurrences(of: "&quot;", with: "\"")
        .replacingOccurrences(of: "&#39;", with: "'")
        // Decode &amp; last so an encoded entity like "&amp;lt;" yields "&lt;", not "<".
        .replacingOccurrences(of: "&amp;", with: "&")
        // Collapse the runs of whitespace the block substitutions may have introduced.
        .replacingOccurrences(of: " {2,}", with: " ", options: .regularExpression)
        .trim()
    }

    public var isNotBlank: Bool {
        !isBlank
    }
}

extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    public var isNilOrBlank: Bool {
        self?.isBlank ?? true
    }

    public var orEmpty: String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .some(let value):
            return value
        case .none:
            return ""
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
