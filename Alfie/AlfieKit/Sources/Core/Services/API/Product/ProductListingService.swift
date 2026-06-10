import Foundation
import Model

/// Stateless paginated product fetcher. Owns no cursor state — callers (the ViewModel,
/// in practice) are responsible for tracking `pagination.endCursor` / `hasNextPage` from
/// the previous response and passing the cursor back in as `after`.
public final class ProductListingService: ProductListingServiceProtocol {
    private let productService: ProductServiceProtocol
    private let searchService: SearchServiceProtocol
    private let configuration: PaginationConfiguration

    // MARK: - Public

    public init(
        productService: ProductServiceProtocol,
        searchService: SearchServiceProtocol,
        configuration: PaginationConfiguration
    ) {
        self.productService = productService
        self.searchService = searchService
        self.configuration = configuration
    }

    public func productListPage(
        collectionHandle: String,
        after: String?,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        try await productService.productList(
            collectionHandle: collectionHandle,
            after: after,
            limit: configuration.pageSize,
            sort: sort,
            filters: filters
        )
    }

    public func searchPage(
        searchTerm: String,
        after: String?,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        try await searchService.searchProducts(
            searchTerm: searchTerm,
            after: after,
            limit: configuration.pageSize,
            sort: sort,
            filters: filters
        )
    }
}

// MARK: - Configuration

extension ProductListingService {
    public struct PaginationConfiguration {
        public enum ListingType {
            case plp
        }

        private enum Constants {
            static let defaultPageSize = 20
        }

        private let type: ListingType

        public init(type: ListingType) {
            self.type = type
        }

        var pageSize: Int {
            switch type {
            case .plp:
                Constants.defaultPageSize
            }
        }
    }
}
