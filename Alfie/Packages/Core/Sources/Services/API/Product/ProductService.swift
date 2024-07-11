import Foundation
import Models

public final class ProductService: ProductServiceProtocol {
    private let bffClient: BFFClientServiceProtocol

    // MARK: - Public

    public init(bffClient: BFFClientServiceProtocol) {
        self.bffClient = bffClient
    }

    public func getProduct(id: String) async throws -> Product {
        do {
            return try await bffClient.getProduct(id: id)
        } catch let error as BFFRequestError where error.isNotFound {
            throw BFFRequestError(type: .product(.noProduct))
        } catch {
            throw BFFRequestError(type: .product(.generic))
        }
    }

    public func productListing(offset: Int, limit: Int, categoryId: String?, query: String?) async throws -> ProductListing {
        guard let productListing = try? await bffClient.productListing(offset: offset,
                                                                       limit: limit,
                                                                       categoryId: categoryId,
                                                                       query: query)
        else {
            throw BFFRequestError(type: .product(.noProducts(category: categoryId, query: query)))
        }
        return productListing
    }
}
