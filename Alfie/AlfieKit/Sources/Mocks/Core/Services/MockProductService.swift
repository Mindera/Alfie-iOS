import Foundation
import Model

public final class MockProductService: ProductServiceProtocol {
    public init() { }

    public var onGetProductCalled: ((String, BFFPlatform) throws -> Product)?
    public func getProduct(handle: String, platform: BFFPlatform) async throws -> Product {
        guard let product = try onGetProductCalled?(handle, platform) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return product
    }

    public var onProductListingCalled: ((String?, Int, String?, String?, String?, ProductFilterInput?) throws -> ProductListing)?
    public func productListing(after: String?, limit: Int, categoryId: String?, query: String?, sort: String?, filters: ProductFilterInput?) async throws -> ProductListing {
        guard let productListing = try onProductListingCalled?(after, limit, categoryId, query, sort, filters) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return productListing
    }
}
