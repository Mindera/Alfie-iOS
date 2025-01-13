import Foundation

public struct Version: Equatable, Comparable {
    public private(set) var stringValue: String

    public init(_ version: String) {
        self.stringValue = version
    }

    // MARK: - Equatable

    public static func == (lhs: Version, rhs: Version) -> Bool {
        lhs.stringValue.versionCompare(rhs.stringValue) == .orderedSame
    }

    // MARK: - Comparable

    public static func <= (lhs: Version, rhs: Version) -> Bool {
        lhs.stringValue.versionCompare(rhs.stringValue) != .orderedDescending
    }

    public static func < (lhs: Version, rhs: Version) -> Bool {
        lhs.stringValue.versionCompare(rhs.stringValue) == .orderedAscending
    }

    public static func >= (lhs: Version, rhs: Version) -> Bool {
        lhs.stringValue.versionCompare(rhs.stringValue) != .orderedAscending
    }

    public static func > (lhs: Version, rhs: Version) -> Bool {
        lhs.stringValue.versionCompare(rhs.stringValue) == .orderedDescending
    }
}

extension String {
    public func versionCompare(_ otherVersion: String) -> ComparisonResult {
        var version1 = self
        var version2 = otherVersion

        let delimiter = "."

        var parts1 = version1.components(separatedBy: delimiter)
        var parts2 = version2.components(separatedBy: delimiter)

        let diff = parts1.count - parts2.count

        if diff < 0 {
            parts1.append(contentsOf: Array(repeating: "0", count: -diff))
            version1 = parts1.joined(separator: delimiter)
        } else if diff > 0 {
            parts2.append(contentsOf: Array(repeating: "0", count: diff))
            version2 = parts2.joined(separator: delimiter)
        }

        return version1.compare(version2, options: .numeric)
    }
}
