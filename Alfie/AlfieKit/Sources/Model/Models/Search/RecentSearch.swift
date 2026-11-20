public enum RecentSearch {
    case text(value: String)
    case brand(name: String, key: String)
}

public extension RecentSearch {
    var value: String {
        switch self {
        case .text(let value):
            value

        case .brand(let name, _):
            name
        }
    }
}

extension RecentSearch: Equatable {}
extension RecentSearch: Hashable {}
extension RecentSearch: Codable {}
