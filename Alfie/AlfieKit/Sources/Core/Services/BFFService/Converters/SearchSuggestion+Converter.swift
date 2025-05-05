import BFFGraph
import Foundation
import Model

extension BFFGraphAPI.GetSuggestionsQuery.Data.Suggestion {
    public func convertToSearchSuggestion() -> SearchSuggestion {
        SearchSuggestion(
            brands: brands.map { $0.fragments.suggestionBrandFragment.convertToSearchSuggestionBrand() },
            keywords: keywords.map { $0.fragments.suggestionKeywordFragment.convertToSearchSuggestionKeyword() },
            products: products.map { $0.fragments.suggestionProductFragment.convertToSearchSuggestionProduct() }
        )
    }
}

extension BFFGraphAPI.SuggestionBrandFragment {
    func convertToSearchSuggestionBrand() -> SearchSuggestionBrand {
        SearchSuggestionBrand(name: value, slug: slug, resultCount: results)
    }
}

extension BFFGraphAPI.SuggestionKeywordFragment {
    func convertToSearchSuggestionKeyword() -> SearchSuggestionKeyword {
        SearchSuggestionKeyword(term: value, resultCount: results)
    }
}

extension BFFGraphAPI.SuggestionProductFragment {
    func convertToSearchSuggestionProduct() -> SearchSuggestionProduct {
        SearchSuggestionProduct(
            id: id,
            name: name,
            brandName: brandName,
            media: media.compactMap { $0.fragments.mediaFragment.convertToMedia() },
            price: price.fragments.priceFragment.convertToPrice(),
            slug: slug
        )
    }
}
