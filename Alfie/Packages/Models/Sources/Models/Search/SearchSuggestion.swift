import Foundation

public struct SearchSuggestion: Identifiable, Equatable, Hashable {
    /// Local Unique ID for the instance (not mapped to any remote value)
    public let id: String
    /// An array of suggested brands.
    public let brands: [SearchSuggestionBrand]
    /// An array of potential search terms.
    public let keywords: [SearchSuggestionKeyword]
    /// An array of suggested products.
    public let products: [SearchSuggestionProduct]

    public init(id: String = UUID().uuidString,
                brands: [SearchSuggestionBrand],
                keywords: [SearchSuggestionKeyword],
                products: [SearchSuggestionProduct]) {
        self.id = id
        self.brands = brands
        self.keywords = keywords
        self.products = products
    }
}
