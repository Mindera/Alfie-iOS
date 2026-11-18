import Foundation
import Model

public final class MockSearchService: SearchServiceProtocol {
    public init() { }

    public var onSearchProductsCalled: ((String, String?, Int, String?, ProductFilterInput?) throws -> ProductListing)?
    public func searchProducts(
        searchTerm: String,
        after: String?,
        limit: Int,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        guard let productListing = try onSearchProductsCalled?(searchTerm, after, limit, sort, filters) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return productListing
    }

    public var onSuggestionsCalled: ((String, Int) async throws -> SearchSuggestions)?
    public func suggestions(searchTerm: String, limit: Int) async throws -> SearchSuggestions {
        guard let suggestions = try await onSuggestionsCalled?(searchTerm, limit) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return suggestions
    }
}
