import Foundation
import Model

public final class ProductService: ProductServiceProtocol {
    private let bffClient: BFFClientServiceProtocol

    // MARK: - Public

    public init(bffClient: BFFClientServiceProtocol) {
        self.bffClient = bffClient
    }

    public func getProduct(handle: String) async throws -> Product {
        try await bffClient.getProduct(handle: handle)
    }

    public func productByBarcode(_ barcode: String) async throws -> BarcodeMatch? {
        try await bffClient.productByBarcode(barcode)
    }

    public func productList(
        collectionHandle: String,
        after: String?,
        limit: Int,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        try await bffClient.productList(
            collectionHandle: collectionHandle,
            after: after,
            limit: limit,
            sort: sort,
            filters: filters
        )
    }

    public func categoryPriceRange(collectionHandle: String) async throws -> PriceRange? {
        try await bffClient.categoryPriceRange(collectionHandle: collectionHandle)
    }

    public func relatedProducts(handle: String, limit: Int) async throws -> [Product] {
        try await bffClient.relatedProducts(handle: handle, limit: limit)
    }
}
