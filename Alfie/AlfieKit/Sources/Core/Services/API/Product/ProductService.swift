import Foundation
import Model

public final class ProductService: ProductServiceProtocol {
    private let bffClient: BFFClientServiceProtocol

    // MARK: - Public

    public init(bffClient: BFFClientServiceProtocol) {
        self.bffClient = bffClient
    }

    public func getProduct(handle: String) async throws -> Product {
        do {
            return try await bffClient.getProduct(handle: handle)
        } catch let error as CancellationError {
            // Cancellation is a control-flow signal, not a domain failure: flattening it into a
            // product error shows an error state for a request that never failed. Every method
            // here rethrows it unmapped so a caller that guards on it can stay silent.
            throw error
        } catch let error as BFFRequestError where error.isNotFound {
            throw BFFRequestError(type: .product(.noProduct))
        } catch {
            throw BFFRequestError(type: .product(.generic))
        }
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
        do {
            return try await bffClient.relatedProducts(handle: handle, limit: limit)
        } catch let error as CancellationError {
            throw error
        } catch {
            throw BFFRequestError(type: .product(.generic))
        }
    }
}
