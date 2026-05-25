import Foundation
import Model

/// Product pagination service.
/// - Internally tracks the BFF's cursor state (`endCursor` / `hasNextPage`) across calls.
/// - Each use case / screen must create its own instance so cursor state isn't shared.
public final class ProductListingService: ProductListingServiceProtocol {
    private let productService: ProductServiceProtocol
    private let configuration: PaginationConfiguration

    private var endCursor: String?
    private var hasNextPage: Bool = false
    private var total: Int?

    // MARK: - Public

    /// Initialise a product listing instance.
    /// - Parameters:
    ///   - productService: service to fetch products from BFF client
    ///   - configuration: page-size configuration
    public init(productService: ProductServiceProtocol, configuration: PaginationConfiguration) {
        self.productService = productService
        self.configuration = configuration
    }

    /// Total number of items available, as reported by the BFF.
    public var totalOfRecords: Int? {
        total
    }

    /// Fetch the first page and reset cursor state.
    public func paged(
        categoryId: String? = nil,
        query: String? = nil,
        sort: String? = nil,
        filters: ProductFilterInput? = nil
    ) async throws -> ProductListing {
        let result = try await productService.productListing(
            after: nil,
            limit: configuration.pageSize,
            categoryId: categoryId,
            query: query,
            sort: sort,
            filters: filters
        )
        updateState(from: result.pagination)
        return result
    }

    /// Whether the BFF has more records after the last fetched page.
    public func hasNext() -> Bool {
        hasNextPage
    }

    /// Fetch the next page using the stored cursor. Throws if no next page is available.
    public func next(
        categoryId: String? = nil,
        query: String? = nil,
        sort: String? = nil,
        filters: ProductFilterInput? = nil
    ) async throws -> ProductListing {
        guard hasNextPage, let endCursor else {
            throw BFFRequestError(type: .product(.noProducts(category: categoryId, query: query, sort: sort)))
        }
        let result = try await productService.productListing(
            after: endCursor,
            limit: configuration.pageSize,
            categoryId: categoryId,
            query: query,
            sort: sort,
            filters: filters
        )
        updateState(from: result.pagination)
        return result
    }

    // MARK: - Private

    private func updateState(from pagination: ProductListing.Pagination) {
        endCursor = pagination.endCursor
        hasNextPage = pagination.hasNextPage
        total = pagination.total
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
