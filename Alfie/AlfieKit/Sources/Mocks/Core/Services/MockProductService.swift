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

    public var onProductByBarcodeCalled: ((String) async throws -> BarcodeMatch?)?
    public func productByBarcode(_ barcode: String) async throws -> BarcodeMatch? {
        try await onProductByBarcodeCalled?(barcode)
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

    public var onCategoryPriceRangeCalled: ((String) throws -> PriceRange?)?
    public func categoryPriceRange(collectionHandle: String) async throws -> PriceRange? {
        try onCategoryPriceRangeCalled?(collectionHandle)
    }

    public var onRelatedProductsCalled: ((String, Int) async throws -> [Product])?
    public func relatedProducts(handle: String, limit: Int) async throws -> [Product] {
        guard let products = try await onRelatedProductsCalled?(handle, limit) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return products
    }
}
