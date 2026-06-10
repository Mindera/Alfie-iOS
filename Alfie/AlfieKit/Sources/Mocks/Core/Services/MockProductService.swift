import Foundation
import Model

public final class MockProductService: ProductServiceProtocol {
    public init() { }

    public var onGetProductCalled: ((String) throws -> Product)?
    public func getProduct(handle: String) async throws -> Product {
        guard let product = try onGetProductCalled?(handle) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return product
    }

    public var onProductListCalled: ((String, String?, Int, String?, ProductFilterInput?) throws -> ProductListing)?
    public func productList(
        collectionHandle: String,
        after: String?,
        limit: Int,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        guard let productListing = try onProductListCalled?(collectionHandle, after, limit, sort, filters) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return productListing
    }
}
