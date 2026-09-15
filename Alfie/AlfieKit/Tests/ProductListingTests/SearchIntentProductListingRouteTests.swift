import Mocks
import Model
import ProductDetails
import Search
import XCTest
@testable import ProductListing

final class SearchIntentProductListingRouteTests: XCTestCase {
    func test_aProductIDRouteOpensTheProductByID() {
        XCTAssertEqual(
            SearchIntent(route: .productDetails(.productDetails(.id("p1")))),
            .productDetails(productID: "p1", product: nil)
        )
    }

    func test_aHandleRouteOpensTheProductByHandle() {
        XCTAssertEqual(
            SearchIntent(route: .productDetails(.productDetails(.deepLink(handle: "blue-shirt", sku: "sku-1")))),
            .productDetails(productID: "blue-shirt", product: nil)
        )
    }

    func test_aProductRouteCarriesTheProduct() {
        let product = Product.fixture(id: "p1")

        XCTAssertEqual(
            SearchIntent(route: .productDetails(.productDetails(.product(product)))),
            .productDetails(productID: "p1", product: product)
        )
    }

    func test_aSelectedProductRouteCarriesItsProduct() {
        let product = Product.fixture(id: "p1")

        XCTAssertEqual(
            SearchIntent(route: .productDetails(.productDetails(.selectedProduct(SelectedProduct(product: product))))),
            .productDetails(productID: "p1", product: product)
        )
    }

    func test_aWebFeatureRouteOpensTheWebFeature() {
        XCTAssertEqual(
            SearchIntent(route: .productDetails(.webFeature(.returnOptions))),
            .webFeature(.returnOptions)
        )
    }

    func test_aListingRouteKeepsItsSearchTermAndCategory() {
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
