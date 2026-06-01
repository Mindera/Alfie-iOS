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
    /// Regex-based (not `NSAttributedString`) so it is deterministic and safe to call
    /// off the main thread — the BFF response converter runs on a background task.
    public func strippingHTML() -> String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            // Decode &amp; last so an encoded entity like "&amp;lt;" yields "&lt;", not "<".
            .replacingOccurrences(of: "&amp;", with: "&")
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
