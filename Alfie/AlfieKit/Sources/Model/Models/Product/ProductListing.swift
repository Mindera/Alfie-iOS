import Foundation

public struct ProductListing {
    /// Cursor-based pagination state returned by the BFF's `productList` query.
    public struct Pagination {
        /// Total number of records available for the query, when reported by the BFF.
        public let total: Int
        /// Opaque cursor pointing at the last record returned by this response — pass back
        /// as `after` to fetch the next page. `nil` when there is no further page.
        public let endCursor: String?
        /// Whether the BFF has more records after this page.
        public let hasNextPage: Bool

        public init(total: Int, endCursor: String?, hasNextPage: Bool) {
            self.total = total
            self.endCursor = endCursor
            self.hasNextPage = hasNextPage
        }
    }

    public let title: String
    public let pagination: Pagination
    public let products: [Product]

    public init(title: String, pagination: Pagination, products: [Product]) {
        self.title = title
        self.pagination = pagination
        self.products = products
    }
}
