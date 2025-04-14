import Foundation

public protocol ProductListingServiceProtocol {
    var totalOfRecords: Int? { get }

    func paged(categoryId: String?, query: String?, sort: String?) async throws -> ProductListing
    func hasNext() -> Bool
    func next(categoryId: String?, query: String?, sort: String?) async throws -> ProductListing
}
