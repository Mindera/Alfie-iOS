import Foundation

public protocol ProductServiceProtocol {
    func getProduct(handle: String) async throws -> Product
    func productList(
        collectionHandle: String,
        after: String?,
        limit: Int,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing
}
