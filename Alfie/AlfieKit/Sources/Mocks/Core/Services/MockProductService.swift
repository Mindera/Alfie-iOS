import Foundation
import Models

public final class MockProductService: ProductServiceProtocol {
    public init() { }

    public var onGetProductCalled: ((String) throws -> Product)?
    public func getProduct(id: String) async throws -> Product {
        guard let product = try onGetProductCalled?(id) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return product
    }

    public var onProductListingCalled: ((Int, Int, String?, String?, String?) throws -> ProductListing)?
    public func productListing(offset: Int, limit: Int, categoryId: String?, query: String?, sort: String?) async throws -> ProductListing {
        guard let productListing = try onProductListingCalled?(offset, limit, categoryId, query, sort) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return productListing
    }
}
