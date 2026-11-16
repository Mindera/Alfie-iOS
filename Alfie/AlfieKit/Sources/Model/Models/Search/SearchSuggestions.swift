import Foundation

public struct SearchSuggestions: Equatable {
    public let keywords: [KeywordSuggestion]
    public let brands: [BrandSuggestion]
    public let products: [ProductSuggestion]

    public init(keywords: [KeywordSuggestion], brands: [BrandSuggestion], products: [ProductSuggestion]) {
        self.keywords = keywords
        self.brands = brands
        self.products = products
    }
}

public struct KeywordSuggestion: Equatable {
    public let value: String

    public init(value: String) {
        self.value = value
    }
}

public struct BrandSuggestion: Equatable {
    public let key: String
    public let name: String

    public init(key: String, name: String) {
        self.key = key
        self.name = name
    }
}

public struct ProductSuggestion: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let brandName: String?
    public let slug: String
    public let price: Money?
    public let imageURL: URL?

    public init(id: String, name: String, brandName: String?, slug: String, price: Money?, imageURL: URL?) {
        self.id = id
        self.name = name
        self.brandName = brandName
        self.slug = slug
        self.price = price
        self.imageURL = imageURL
    }
}
