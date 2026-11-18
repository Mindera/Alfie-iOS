import Foundation

public protocol SearchServiceProtocol {
    func searchProducts(
        searchTerm: String,
        after: String?,
        limit: Int,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing

    func suggestions(searchTerm: String, limit: Int) async throws -> SearchSuggestions
}
