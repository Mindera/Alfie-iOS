import Foundation
import Model

extension SearchSuggestions {
    public static func fixture(
        keywords: [KeywordSuggestion] = [],
        brands: [BrandSuggestion] = [],
        products: [ProductSuggestion] = []
    ) -> SearchSuggestions {
        .init(keywords: keywords, brands: brands, products: products)
    }
}

extension KeywordSuggestion {
    public static func fixture(value: String = "linen shirt") -> KeywordSuggestion {
        .init(value: value)
    }
}

extension BrandSuggestion {
    public static func fixture(key: String = "alfie", name: String = "Alfie") -> BrandSuggestion {
        .init(key: key, name: name)
    }
}

extension ProductSuggestion {
    public static func fixture(
        id: String = "1",
        name: String = "Oxford Shirt",
        brandName: String? = "Alfie",
        handle: String = "oxford-shirt",
        price: Money? = .fixture(),
        imageURL: URL? = nil
    ) -> ProductSuggestion {
        .init(id: id, name: name, brandName: brandName, handle: handle, price: price, imageURL: imageURL)
    }
}
