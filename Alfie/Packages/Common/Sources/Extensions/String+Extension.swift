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
        switch self {
            case .some(let value):
                return value
            case .none:
                return ""
        }
    }
}
