import XCTest
import ApolloTestSupport
import BFFGraphAPI
import BFFGraphMocks

final class ProductListingConverterTests: XCTestCase {
    func test_product_listing_valid() {
        let pagination = Mock<Pagination>(limit: 40,
                                          nextPage: 3,
                                          offset: 20,
                                          page: 2,
                                          pages: 5,
                                          previousPage: 1,
                                          total: 81)

        let mockProductListing = Mock<ProductListing>(pagination: pagination,
                                                      products: [.mock()],
                                                      title: "Product Listing Title")

        let response = BFFGraphAPI.ProductListingQuery.Data.ProductListing.from(mockProductListing)
        let productListing = response.convertToProductListing()

        XCTAssertEqual(productListing.products.count, 1)
        XCTAssertEqual(productListing.title, "Product Listing Title")

        XCTAssertEqual(productListing.pagination.limit, 40)
        XCTAssertEqual(productListing.pagination.nextPage, 3)
        XCTAssertEqual(productListing.pagination.offset, 20)
        XCTAssertEqual(productListing.pagination.page, 2)
        XCTAssertEqual(productListing.pagination.pages, 5)
        XCTAssertEqual(productListing.pagination.previousPage, 1)
        XCTAssertEqual(productListing.pagination.total, 81)
    }
}
