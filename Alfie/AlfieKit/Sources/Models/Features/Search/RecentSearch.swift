public enum RecentSearch {
    case text(value: String)
    case reccomendation(value: String, path: String)
}

public extension RecentSearch {
    var value: String {
        switch self {
        case .text(let value),
             .reccomendation(let value, _): // swiftlint:disable:this indentation_width
            return value
        }
    }
}

extension RecentSearch: Equatable {}
extension RecentSearch: Hashable {}
extension RecentSearch: Codable {}
