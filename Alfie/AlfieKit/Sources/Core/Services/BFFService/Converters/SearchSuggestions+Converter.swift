import BFFGraph
import Foundation
import Model

extension BFFGraphAPI.SuggestionFragment {
    public func convertToSearchSuggestions() -> SearchSuggestions {
        var seenProductIDs = Set<String>()
        return SearchSuggestions(
            keywords: keywords.map { KeywordSuggestion(value: $0.value) },
            brands: brands.map { BrandSuggestion(key: $0.key, name: $0.value) },
            products: products
                .map { $0.fragments.suggestionProductFragment.convertToProductSuggestion() }
                .filter { seenProductIDs.insert($0.id).inserted }
        )
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
