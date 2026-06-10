import Foundation
import Model

public final class MockProductListingService: ProductListingServiceProtocol {
    public init() { }

    public var onProductListPageCalled: ((String, String?, String?, ProductFilterInput?) throws -> ProductListing)?
    public func productListPage(
        collectionHandle: String,
        after: String?,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        guard let productListing = try onProductListPageCalled?(collectionHandle, after, sort, filters) else {
            throw BFFRequestError(type: .product(.noProducts(category: collectionHandle, query: nil, sort: sort)))
        }
        return productListing
    }

    public var onSearchPageCalled: ((String, String?, String?, ProductFilterInput?) throws -> ProductListing)?
    public func searchPage(
        searchTerm: String,
        after: String?,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        guard let productListing = try onSearchPageCalled?(searchTerm, after, sort, filters) else {
            throw BFFRequestError(type: .product(.noProducts(category: nil, query: searchTerm, sort: sort)))
        }
        return productListing
    }
}
