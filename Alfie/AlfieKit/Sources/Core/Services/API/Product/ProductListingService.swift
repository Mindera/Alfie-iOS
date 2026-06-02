import Foundation
import Model

/// Stateless paginated product fetcher. Owns no cursor state — callers (the ViewModel,
/// in practice) are responsible for tracking `pagination.endCursor` / `hasNextPage` from
/// the previous response and passing the cursor back in as `after`.
public final class ProductListingService: ProductListingServiceProtocol {
    private let productService: ProductServiceProtocol
    private let configuration: PaginationConfiguration

    // MARK: - Public

    public init(productService: ProductServiceProtocol, configuration: PaginationConfiguration) {
        self.productService = productService
        self.configuration = configuration
    }

    public func page(
        after: String?,
        categoryId: String? = nil,
        query: String? = nil,
        sort: String? = nil,
        filters: ProductFilterInput? = nil
    ) async throws -> ProductListing {
        try await productService.productListing(
            after: after,
            limit: configuration.pageSize,
            categoryId: categoryId,
            query: query,
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
