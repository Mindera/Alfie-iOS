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
    public static func fixture(offset: Int = 0,
                               limit: Int = 0,
                               total: Int = 0,
                               pages: Int = 0,
                               page: Int = 0,
                               nextPage: Int? = nil,
                               previousPage: Int? = nil) -> ProductListing.Pagination {
        .init(offset: offset,
              limit: limit,
              total: total,
              pages: pages,
              page: page,
              nextPage: nextPage,
              previousPage: previousPage)
    }
}
