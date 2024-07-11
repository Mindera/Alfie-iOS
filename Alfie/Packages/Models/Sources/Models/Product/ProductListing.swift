import Foundation

public struct ProductListing {
    public struct Pagination {
        /// Start point
        public let offset: Int
        /// Records to return
        public let limit: Int
        /// The total number of results
        public let total: Int
        /// Number of pages based on offset
        public let pages: Int
        /// Current page
        public let page: Int
        /// Offset of next page if page exists
        public let nextPage: Int?
        /// Offset of previous page if page exists
        public let previousPage: Int?

        public init(offset: Int,
                    limit: Int,
                    total: Int,
                    pages: Int,
                    page: Int,
                    nextPage: Int? = nil,
                    previousPage: Int? = nil) {
            self.offset = offset
            self.limit = limit
            self.total = total
            self.pages = pages
            self.page = page
            self.nextPage = nextPage
            self.previousPage = previousPage
        }
    }

    public let title: String
    public let pagination: Pagination
    public let products: [Product]

    public init(title: String,
                pagination: Pagination,
                products: [Product]) {
        self.title = title
        self.pagination = pagination
        self.products = products
    }
}
