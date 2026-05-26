import XCTest
import ApolloTestSupport
@testable import BFFGraph
import Core

final class ProductListingConverterTests: XCTestCase {
    func test_product_list_response_converts_to_product_listing() throws {
        let listing = makeResponse(
            brandName: "Acme",
            descriptionHtml: "<p>Hello</p>",
            productId: "prod-1",
            name: "Test Product",
            productType: "Shoes",
            slug: "test-product",
            inventoryTotal: 10,
            amount: 19.99,
            currencyCode: "AUD",
            totalCount: 42,
            endCursor: "cursor-1",
            hasNextPage: true
        ).convertToProductListing()

        XCTAssertEqual(listing.products.count, 1)
        XCTAssertEqual(listing.products.first?.id, "prod-1")
        XCTAssertEqual(listing.products.first?.name, "Test Product")
        XCTAssertEqual(listing.products.first?.brand.name, "Acme")
        XCTAssertEqual(listing.pagination.totalCount, 42)
        XCTAssertEqual(listing.pagination.endCursor, "cursor-1")
        XCTAssertTrue(listing.pagination.hasNextPage)
    }

    func test_empty_products_yields_empty_listing() {
        let listing = makeResponse(products: [], totalCount: 0, endCursor: nil, hasNextPage: false)
            .convertToProductListing()

        XCTAssertTrue(listing.products.isEmpty)
        XCTAssertEqual(listing.pagination.totalCount, 0)
        XCTAssertNil(listing.pagination.endCursor)
        XCTAssertFalse(listing.pagination.hasNextPage)
    }

    func test_missing_totalCount_passes_through_as_nil() {
        // BFF omits totalCount → converter must preserve nil, not invent products.count.
        let listing = makeResponse(totalCount: nil).convertToProductListing()

        XCTAssertNil(listing.pagination.totalCount)
    }

    func test_drops_high_when_price_range_min_equals_max() {
        let listing = makeResponse(amount: 25.00).convertToProductListing()

        XCTAssertEqual(listing.products.first?.priceRange?.low.amount, 2500)
        XCTAssertNil(listing.products.first?.priceRange?.high)
    }

    func test_preserves_price_range_when_min_differs_from_max() {
        let listing = makeResponse(amount: 10.00, highAmount: 50.00).convertToProductListing()

        XCTAssertEqual(listing.products.first?.priceRange?.low.amount, 1000)
        XCTAssertEqual(listing.products.first?.priceRange?.high?.amount, 5000)
    }

    func test_primary_image_maps_to_default_variant_media() throws {
        let listing = makeResponse(
            primaryImage: Mock<Image>(altText: "Hero alt", url: "https://cdn.alfie.test/p1.jpg")
        ).convertToProductListing()

        let domainProduct = try XCTUnwrap(listing.products.first)
        let mediaImage = try XCTUnwrap(domainProduct.defaultVariant.media.first?.asImage)
        XCTAssertEqual(mediaImage.url.absoluteString, "https://cdn.alfie.test/p1.jpg")
        XCTAssertEqual(mediaImage.alt, "Hero alt")
    }

    func test_missing_primary_image_yields_no_default_variant_media() throws {
        let listing = makeResponse(primaryImage: nil).convertToProductListing()

        let domainProduct = try XCTUnwrap(listing.products.first)
        XCTAssertTrue(domainProduct.defaultVariant.media.isEmpty)
    }

    func test_money_rounding_edge_cases() throws {
        // Float→Int via `Int((amount * 100).rounded())` — boundary cases prove the
        // rounding behaviour we depend on for currency representation.
        let cases: [(amount: Double, expectedMinorUnits: Int)] = [
            (0.00, 0),
            (0.01, 1),
            (0.10, 10),
            (19.99, 1999),
            (100.00, 10000),
            (1234.567, 123457)
        ]

        for (amount, expectedMinorUnits) in cases {
            let listing = makeResponse(amount: amount).convertToProductListing()
            let mapped = try XCTUnwrap(listing.products.first?.priceRange?.low.amount)
            XCTAssertEqual(
                mapped, expectedMinorUnits,
                "amount \(amount) should round to \(expectedMinorUnits) minor units, got \(mapped)"
            )
        }
    }

    func test_invalid_primary_image_url_yields_no_media() throws {
        // Empty URL string makes URL(string:) return nil → converter must skip media
        // gracefully instead of crashing or fabricating a placeholder.
        let listing = makeResponse(primaryImage: Mock<Image>(altText: "bogus", url: ""))
            .convertToProductListing()

        let domainProduct = try XCTUnwrap(listing.products.first)
        XCTAssertTrue(domainProduct.defaultVariant.media.isEmpty)
    }

    func test_missing_brand_name_falls_back_to_empty_string() {
        let listing = makeResponse(brandName: nil).convertToProductListing()

        XCTAssertEqual(listing.products.first?.brand.name, "")
    }
}

// MARK: - Test factory

private extension ProductListingConverterTests {
    /// Builds an Apollo `ProductListQuery.Data.ProductList` from a single mocked
    /// `OmniProduct`. Defaults cover the common case so each test only declares the
    /// fields it actually exercises. Tests call `.convertToProductListing()` on the
    /// result to obtain the domain `ProductListing`.
    ///
    /// Pass `products: []` to bypass the single-product builder entirely (empty-listing
    /// path). `highAmount` defaults to `nil`, in which case min == max; supply a value
    /// to drive the ranged-price scenario.
    func makeResponse(
        brandName: String? = "Acme",
        descriptionHtml: String? = nil,
        productId: String = "p1",
        name: String = "Product",
        productType: String? = nil,
        slug: String = "p1",
        inventoryTotal: Int? = nil,
        amount: Double = 5.00,
        highAmount: Double? = nil,
        currencyCode: String = "GBP",
        primaryImage: Mock<Image>? = nil,
        products: [Mock<OmniProduct>]? = nil,
        totalCount: Int? = 1,
        endCursor: String? = nil,
        hasNextPage: Bool = false
    ) -> BFFGraphAPI.ProductListQuery.Data.ProductList {
        let low = Mock<Money>(amount: amount, currencyCode: currencyCode)
        let high = highAmount.map { Mock<Money>(amount: $0, currencyCode: currencyCode) } ?? low
        let priceRange = Mock<MoneyRange>(maxVariantPrice: high, minVariantPrice: low)
        let defaultProduct = Mock<OmniProduct>(
            brandName: brandName,
            descriptionHtml: descriptionHtml,
            id: productId,
            inventoryTotal: inventoryTotal,
            name: name,
            priceRange: priceRange,
            primaryImage: primaryImage,
            productType: productType,
            slug: slug
        )
        let pageInfo = Mock<PageInfo>(endCursor: endCursor, hasNextPage: hasNextPage)
        let response = Mock<ProductListResponse>(
            pageInfo: pageInfo,
            products: products ?? [defaultProduct],
            totalCount: totalCount
        )
        return BFFGraphAPI.ProductListQuery.Data.ProductList.from(response)
    }
}
