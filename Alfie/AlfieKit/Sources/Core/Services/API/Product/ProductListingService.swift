import Foundation
import Models

/// Product pagination service
/// - internally manages the following pages to fetch based on the pagination information provided by the BFF API
/// - each use case/screen must create an instance
public final class ProductListingService: ProductListingServiceProtocol {
    private let productService: ProductServiceProtocol
    private let configuration: PaginationConfiguration

    private var pagination: ProductListing.Pagination?

    // MARK: - Public

    /// Initialise a product listing instance.
    /// - Parameters:
    ///   - productService: service to fetch products from BFF client
    ///   - configuration: internal pagination details
    public init(productService: ProductServiceProtocol, configuration: PaginationConfiguration) {
        self.productService = productService
        self.configuration = configuration
    }

    /// Total number of items available
    public var totalOfRecords: Int? {
        pagination?.total
    }

    /// Fetch the initial page (offset) and update local pagination information
    /// Offset starts at 0
    public func paged(
        categoryId: String? = nil,
        query: String? = nil,
        sort: String? = nil
    ) async throws -> ProductListing {
        let result = try await productService.productListing(
            offset: configuration.initialPage,
            limit: configuration.pageSize,
            categoryId: categoryId,
            query: query,
            sort: sort
        )
        pagination = result.pagination
        return result
    }

    /// Check offset of next page if page exists based on `pageSize`
    public func hasNext() -> Bool {
        pagination?.nextPage != nil
    }

    /// Fetch following page while there is a next page and update local pagination information
    public func next(
        categoryId: String? = nil,
        query: String? = nil,
        sort: String? = nil
    ) async throws -> ProductListing {
        guard let nextPage = pagination?.nextPage else {
            throw BFFRequestError(type: .product(.noProducts(category: categoryId, query: query, sort: sort)))
        }
        let result = try await productService.productListing(
            offset: nextPage,
            limit: configuration.pageSize,
            categoryId: categoryId,
            query: query,
            sort: sort
        )
        pagination = result.pagination
        return result
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
        let initialPage: Int

        public init(type: ListingType, initialPage: Int = 0) {
            self.type = type
            self.initialPage = initialPage
        }

        var pageSize: Int {
            switch type {
            case .plp:
                Constants.defaultPageSize
            }
        }
    }
}
