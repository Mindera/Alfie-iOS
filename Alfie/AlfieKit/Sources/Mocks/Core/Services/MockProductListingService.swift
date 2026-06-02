import Foundation
import Model

public final class MockProductListingService: ProductListingServiceProtocol {
    public init() { }

    public var onPageCalled: ((String?, String?, String?, String?, ProductFilterInput?) throws -> ProductListing)?
    public func page(
        after: String?,
        categoryId: String?,
        query: String?,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        guard let productListing = try onPageCalled?(after, categoryId, query, sort, filters) else {
            throw BFFRequestError(type: .product(.noProducts(category: categoryId, query: query, sort: sort)))
        }
        return productListing
    }
}
