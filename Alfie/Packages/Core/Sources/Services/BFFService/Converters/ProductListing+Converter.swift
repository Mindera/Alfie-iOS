import BFFGraphApi
import Common
import Foundation
import Models

extension ProductListingQuery.Data.ProductListing {
    public func convertToProductListing() -> ProductListing {
        ProductListing(title: title,
                       pagination: pagination.fragments.paginationFragment.convertToPagination(),
                       products: products.map { $0.fragments.productFragment.convertToProduct() })
    }
}

extension PaginationFragment {
    func convertToPagination() -> ProductListing.Pagination {
        ProductListing.Pagination(offset: offset,
                                  limit: limit,
                                  total: total,
                                  pages: pages,
                                  page: page,
                                  nextPage: nextPage,
                                  previousPage: previousPage)
    }
}
