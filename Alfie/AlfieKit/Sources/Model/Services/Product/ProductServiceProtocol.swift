import Foundation

public protocol ProductServiceProtocol {
    func getProduct(id: String) async throws -> Product
    func productListing(
        after: String?,
        limit: Int,
        categoryId: String?,
        query: String?,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing
}
