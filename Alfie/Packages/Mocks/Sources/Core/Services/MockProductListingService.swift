import Foundation
import Models

public final class MockProductListingService: ProductListingServiceProtocol {
    public init() { }

    public var totalOfRecords: Int? = 0

    public var onPageCalled: ((String?, String?) throws -> ProductListing)?
    public func paged(categoryId: String?, query: String?) async throws -> Models.ProductListing {
        guard let productListing = try onPageCalled?(categoryId, query) else {
            throw BFFRequestError(type: .product(.noProducts(category: categoryId, query: query)))
        }
        return productListing
    }

    public var onHasNextCalled: (() -> Bool)?
    public func hasNext() -> Bool {
        onHasNextCalled?() ?? false
    }

    public var onNextCalled: ((String?, String?) throws -> ProductListing)?
    public func next(categoryId: String?, query: String?) async throws -> ProductListing {
        guard let productListing = try onNextCalled?(categoryId, query) else {
            throw BFFRequestError(type: .product(.noProducts(category: categoryId, query: query)))
        }
        return productListing
    }
}
