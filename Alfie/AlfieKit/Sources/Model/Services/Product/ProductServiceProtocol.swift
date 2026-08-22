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
    /// Whole-collection price bounds, independent of any active filter. `nil` when the BFF has
    /// no range for the collection.
    func categoryPriceRange(collectionHandle: String) async throws -> PriceRange?
}
