import BFFGraph
import Foundation
import Model

extension BFFGraphAPI.SuggestionsQuery.Data.Suggestion {
    public func convertToSearchSuggestions() -> SearchSuggestions {
        SearchSuggestions(
            keywords: keywords.map { KeywordSuggestion(value: $0.value) },
            brands: brands.map { BrandSuggestion(key: $0.key, name: $0.value) },
            products: products.map { product in
                ProductSuggestion(
                    id: product.id,
                    name: product.name,
                    brandName: product.brandName,
                    slug: product.slug,
                    price: product.price?.fragments.moneyFragment.toDomainMoneyIfRenderable(),
                    imageURL: product.images.first.flatMap { URL(string: $0.fragments.imageFragment.url) }
                )
            }
        )
    }
}
