import XCTest
import ApolloTestSupport
@testable import BFFGraph
import Core

final class ProductListingConverterTests: XCTestCase {
    func test_product_list_response_converts_to_product_listing() {
        let money = Mock<Money>(amount: 19.99, currencyCode: "AUD")
        let priceRange = Mock<MoneyRange>(maxVariantPrice: money, minVariantPrice: money)
        let product = Mock<OmniProduct>(
            brandName: "Acme",
            descriptionHtml: "<p>Hello</p>",
            id: "prod-1",
            inventoryTotal: 10,
            name: "Test Product",
            priceRange: priceRange,
            productType: "Shoes",
            slug: "test-product"
        )
        let pageInfo = Mock<PageInfo>(endCursor: "cursor-1", hasNextPage: true)
        let mockResponse = Mock<ProductListResponse>(pageInfo: pageInfo, products: [product], totalCount: 42)

        let response = BFFGraphAPI.ProductListQuery.Data.ProductList.from(mockResponse)
        let listing = response.convertToProductListing()

        XCTAssertEqual(listing.products.count, 1)
        XCTAssertEqual(listing.products.first?.id, "prod-1")
        XCTAssertEqual(listing.products.first?.name, "Test Product")
        XCTAssertEqual(listing.products.first?.brand.name, "Acme")
        XCTAssertEqual(listing.pagination.totalCount, 42)
        XCTAssertEqual(listing.pagination.endCursor, "cursor-1")
        XCTAssertTrue(listing.pagination.hasNextPage)
    }

    func test_empty_products_yields_empty_listing() {
        let pageInfo = Mock<PageInfo>(endCursor: nil, hasNextPage: false)
        let mockResponse = Mock<ProductListResponse>(pageInfo: pageInfo, products: [], totalCount: 0)

        let response = BFFGraphAPI.ProductListQuery.Data.ProductList.from(mockResponse)
        let listing = response.convertToProductListing()

        XCTAssertTrue(listing.products.isEmpty)
        XCTAssertEqual(listing.pagination.totalCount, 0)
        XCTAssertNil(listing.pagination.endCursor)
        XCTAssertFalse(listing.pagination.hasNextPage)
    }

    func test_collapses_price_range_when_min_equals_max() {
        let money = Mock<Money>(amount: 25.00, currencyCode: "GBP")
        let priceRange = Mock<MoneyRange>(maxVariantPrice: money, minVariantPrice: money)
        let product = Mock<OmniProduct>(id: "p1", name: "Single Price", priceRange: priceRange, slug: "p1")
        let mockResponse = Mock<ProductListResponse>(products: [product], totalCount: 1)

        let response = BFFGraphAPI.ProductListQuery.Data.ProductList.from(mockResponse)
        let listing = response.convertToProductListing()

        XCTAssertEqual(listing.products.first?.priceRange?.low.amount, 2500)
        XCTAssertNil(listing.products.first?.priceRange?.high)
    }

    func test_preserves_price_range_when_min_differs_from_max() {
        let low = Mock<Money>(amount: 10.00, currencyCode: "GBP")
        let high = Mock<Money>(amount: 50.00, currencyCode: "GBP")
        let priceRange = Mock<MoneyRange>(maxVariantPrice: high, minVariantPrice: low)
        let product = Mock<OmniProduct>(id: "p1", name: "Ranged", priceRange: priceRange, slug: "p1")
        let mockResponse = Mock<ProductListResponse>(products: [product], totalCount: 1)

        let response = BFFGraphAPI.ProductListQuery.Data.ProductList.from(mockResponse)
        let listing = response.convertToProductListing()

        XCTAssertEqual(listing.products.first?.priceRange?.low.amount, 1000)
        XCTAssertEqual(listing.products.first?.priceRange?.high?.amount, 5000)
    }

    func test_missing_brand_name_falls_back_to_empty_string() {
        let money = Mock<Money>(amount: 5.00, currencyCode: "GBP")
        let priceRange = Mock<MoneyRange>(maxVariantPrice: money, minVariantPrice: money)
        let product = Mock<OmniProduct>(brandName: nil, id: "p1", name: "No Brand", priceRange: priceRange, slug: "p1")
        let mockResponse = Mock<ProductListResponse>(products: [product], totalCount: 1)

        let response = BFFGraphAPI.ProductListQuery.Data.ProductList.from(mockResponse)
        let listing = response.convertToProductListing()

        XCTAssertEqual(listing.products.first?.brand.name, "")
    }
}
