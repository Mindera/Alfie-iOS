import Mocks
import Model
import ProductDetails
import Search
import XCTest
@testable import ProductListing

final class SearchIntentProductListingRouteTests: XCTestCase {
    func test_init_from_product_id_route_opens_the_product_by_id() {
        XCTAssertEqual(
            SearchIntent(route: .productDetails(.productDetails(.id("p1")))),
            .productDetails(productID: "p1", product: nil)
        )
    }

    func test_init_from_deep_link_handle_route_opens_the_product_by_handle() {
        XCTAssertEqual(
            SearchIntent(route: .productDetails(.productDetails(.deepLink(handle: "blue-shirt", sku: "sku-1")))),
            .productDetails(productID: "blue-shirt", product: nil)
        )
    }

    func test_init_from_product_route_carries_the_product() {
        let product = Product.fixture(id: "p1")

        XCTAssertEqual(
            SearchIntent(route: .productDetails(.productDetails(.product(product)))),
            .productDetails(productID: "p1", product: product)
        )
    }

    func test_init_from_selected_product_route_carries_its_product() {
        let product = Product.fixture(id: "p1")

        XCTAssertEqual(
            SearchIntent(route: .productDetails(.productDetails(.selectedProduct(SelectedProduct(product: product))))),
            .productDetails(productID: "p1", product: product)
        )
    }

    func test_init_from_web_feature_route_opens_the_web_feature() {
        XCTAssertEqual(
            SearchIntent(route: .productDetails(.webFeature(.returnOptions))),
            .webFeature(.returnOptions)
        )
    }

    func test_init_from_listing_route_keeps_its_search_term_and_category() {
        let configuration = ProductListingScreenConfiguration(
            category: "women",
            searchText: "jeans",
            urlQueryParameters: nil,
            mode: .searchResults
        )

        XCTAssertEqual(
            SearchIntent(route: .productListing(configuration)),
            .productListing(searchTerm: "jeans", category: "women")
        )
    }
}
