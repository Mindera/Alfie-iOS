import Foundation

/// Fetches a single page of products. Cursor state lives on the caller (typically a
/// `@MainActor` ViewModel): pass `after: nil` for the first page, then thread
/// `response.pagination.endCursor` back in as long as `pagination.hasNextPage` is true.
public protocol ProductListingServiceProtocol {
    func page(
        after: String?,
        categoryId: String?,
        query: String?,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing
}
