import BFFGraph
import Foundation
import Model

extension BFFGraphAPI.SuggestionFragment {
    public func convertToSearchSuggestions() -> SearchSuggestions {
        var seenKeywords = Set<String>()
        var seenProductIDs = Set<String>()
        return SearchSuggestions(
            keywords: keywords
                .map { $0.fragments.suggestionKeywordFragment.convertToKeywordSuggestion() }
                .filter { seenKeywords.insert($0.value.lowercased()).inserted },
            brands: brands.map { $0.fragments.suggestionBrandFragment.convertToBrandSuggestion() },
            products: products
                .map { $0.fragments.suggestionProductFragment.convertToProductSuggestion() }
                .filter { seenProductIDs.insert($0.id).inserted }
        )
    }
}

extension BFFGraphAPI.SuggestionKeywordFragment {
    public func convertToKeywordSuggestion() -> KeywordSuggestion {
        KeywordSuggestion(value: value)
    }
}

extension BFFGraphAPI.SuggestionBrandFragment {
    public func convertToBrandSuggestion() -> BrandSuggestion {
        BrandSuggestion(key: key, name: value)
    }
}

extension BFFGraphAPI.SuggestionProductFragment {
    public func convertToProductSuggestion() -> ProductSuggestion {
        ProductSuggestion(
            id: id,
            name: name,
            brandName: brandName,
            handle: slug,
            price: price?.fragments.moneyFragment.toDomainMoneyIfRenderable(),
            imageURL: images.first.flatMap { URL(string: $0.fragments.imageFragment.url) }
        )
    }
}
