public enum RecentSearch {
    case text(value: String)
    case brand(suggestion: BrandSuggestion)
}

public extension RecentSearch {
    var value: String {
        switch self {
        case .text(let value):
            value

        case .brand(let brand):
            brand.name
        }
    }

    func isSameSearch(as other: RecentSearch) -> Bool {
        if case let (.brand(brand), .brand(otherBrand)) = (self, other), brand.key == otherBrand.key {
            return true
        }
        return value.caseInsensitiveCompare(other.value) == .orderedSame
    }
}

extension RecentSearch: Equatable {}
extension RecentSearch: Hashable {}
extension RecentSearch: Codable {}
