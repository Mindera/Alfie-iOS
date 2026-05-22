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
    public static func fixture(total: Int = 0,
                               endCursor: String? = nil,
                               hasNextPage: Bool = false) -> ProductListing.Pagination {
        .init(total: total,
              endCursor: endCursor,
              hasNextPage: hasNextPage)
    }
}
