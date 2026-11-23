public enum RecentSearch {
    case text(value: String)
    case brand(BrandSuggestion)
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
        switch (self, other) {
        case let (.brand(brand), .brand(otherBrand)):
            brand.key == otherBrand.key

        default:
            self == other
        }
    }
}

extension RecentSearch: Equatable {}
extension RecentSearch: Hashable {}
extension RecentSearch: Codable {}
