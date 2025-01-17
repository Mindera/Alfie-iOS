import Foundation
import Models

extension SearchSuggestion {
    public static func fixture(id: String = UUID().uuidString,
                               brands: [SearchSuggestionBrand] = [],
                               keywords: [SearchSuggestionKeyword] = [],
                               products: [SearchSuggestionProduct] = []) -> SearchSuggestion {
        .init(id: id,
              brands: brands,
              keywords: keywords,
              products: products)
    }
}

extension SearchSuggestionBrand {
    public static func fixture(id: String = UUID().uuidString,
                               name: String = "",
                               slug: String = "",
                               resultCount: Int = 0) -> SearchSuggestionBrand {
        .init(id: id,
              name: name,
              slug: slug,
              resultCount: resultCount)
    }
}

extension SearchSuggestionKeyword {
    public static func fixture(id: String = UUID().uuidString,
                               term: String = "",
                               resultCount: Int = 0) -> SearchSuggestionKeyword {
        .init(id: id,
              term: term,
              resultCount: resultCount)
    }
}

extension SearchSuggestionProduct {
    public static func fixture(id: String = UUID().uuidString,
                               name: String = "",
                               brandName: String = "",
                               media: [Media] = [],
                               price: Price = .fixture(),
                               slug: String = "") -> SearchSuggestionProduct {
        .init(id: id,
              name: name,
              brandName: brandName,
              media: media,
              price: price,
              slug: slug)
    }
}
