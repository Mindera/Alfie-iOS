import Foundation

public protocol ProductServiceProtocol {
    func getProduct(id: String) async throws -> Product
    func productListing(offset: Int, limit: Int, categoryId: String?, query: String?) async throws -> ProductListing
}
