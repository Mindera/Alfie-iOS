import BFFGraph
import Foundation
import Model
import Utils

extension BFFGraphAPI.SuggestionFragment {
    public func convertToSearchSuggestions() -> SearchSuggestions {
        SearchSuggestions(
            keywords: keywords.map { $0.fragments.suggestionKeywordFragment.convertToKeywordSuggestion() },
            brands: brands.map { $0.fragments.suggestionBrandFragment.convertToBrandSuggestion() },
            products: products
                .map { $0.fragments.suggestionProductFragment.convertToProductSuggestion() }
                .uniqued(on: \.id)
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
        BrandSuggestion(key: key, name: value.trim())
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
