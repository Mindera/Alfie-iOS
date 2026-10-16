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
        do {
            return try await bffClient.productByBarcode(barcode)
        } catch let error as CancellationError {
            throw error
        } catch {
            throw BFFRequestError(type: .product(.generic))
        }
    }

    public func productList(
        collectionHandle: String,
        after: String?,
        limit: Int,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        do {
            return try await bffClient.productList(
                collectionHandle: collectionHandle,
                after: after,
                limit: limit,
                sort: sort,
                filters: filters
            )
        } catch let error as CancellationError {
            // SwiftUI cancels the `.refreshable` task routinely; mapping that here is what raised an
            // error Snackbar over a perfectly good grid. See the note in `getProduct`.
            throw error
        } catch let error as BFFRequestError {
            // Only "no data" responses should surface as a noProducts state; genuine
            // failures (network, decoding, server errors) get the generic product error so
            // the UI can render an error state rather than a misleading empty list.
            switch error.type {
            case .emptyResponse, .product(.noProducts):
                throw BFFRequestError(type: .product(.noProducts(category: collectionHandle, query: nil, sort: sort)))

            default:
                throw BFFRequestError(type: .product(.generic))
            }
        } catch {
            throw BFFRequestError(type: .product(.generic))
        }
    }

    public func categoryPriceRange(collectionHandle: String) async throws -> PriceRange? {
        do {
            return try await bffClient.categoryPriceRange(collectionHandle: collectionHandle)
        } catch let error as CancellationError {
            // See the note in `getProduct`.
            throw error
        } catch {
            throw BFFRequestError(type: .product(.generic))
        }
    }

    public func relatedProducts(handle: String, limit: Int) async throws -> [Product] {
        try await bffClient.relatedProducts(handle: handle, limit: limit)
    }
}
