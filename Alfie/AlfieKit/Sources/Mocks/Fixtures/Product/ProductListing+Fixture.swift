import Foundation
import Model

extension ProductListing {
    public static func fixture(title: String = "",
                               pagination: Pagination = .fixture(),
                               products: [Product] = []) -> ProductListing {
        .init(title: title,
              pagination: pagination,
              products: products)
    }
}

extension ProductListing.Pagination {
    public static func fixture(totalCount: Int = 0,
                               endCursor: String? = nil,
                               hasNextPage: Bool = false) -> ProductListing.Pagination {
        .init(totalCount: totalCount,
              endCursor: endCursor,
              hasNextPage: hasNextPage)
    }
}
