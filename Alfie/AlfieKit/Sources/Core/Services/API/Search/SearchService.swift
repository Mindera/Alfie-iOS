import Foundation
import Model

public final class SearchService: SearchServiceProtocol {
    private let bffClient: BFFClientServiceProtocol

    // MARK: - Public

    public init(bffClient: BFFClientServiceProtocol) {
        self.bffClient = bffClient
    }

    public func searchProducts(
        searchTerm: String,
        after: String?,
        limit: Int,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        try await bffClient.searchProducts(
            searchTerm: searchTerm,
            after: after,
            limit: limit,
            sort: sort,
            filters: filters
        )
    }
}
