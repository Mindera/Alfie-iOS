import AlicerceLogging
import Bag
import CategorySelector
import Home
import Mocks
import Model
import MyAccount
import ProductDetails
import ProductListing
import Wishlist
import XCTest
@testable import AppFeature

/// The table that decides where a deep link lands. Asserted on the `TabRoute` value rather than
/// through `AppFeatureViewModel`, because navigating pushes the route into a `NavigationPath`, which
/// cannot be read back — driving the view model can only show *which tab* was selected, never which
/// screen. `test_navigatingForwardsTheRouteToTheTabs` covers the hand-off itself.
final class DeepLinkRoutingTests: XCTestCase {
    func test_tabLinksOpenTheirTabAtItsRoot() {
        XCTAssertEqual(TabRoute(deepLinkType: .home), .home(.home))
        XCTAssertEqual(TabRoute(deepLinkType: .shop(route: nil)), .shop(.categorySelector))
        XCTAssertEqual(TabRoute(deepLinkType: .bag), .bag(.bag))
        XCTAssertEqual(TabRoute(deepLinkType: .wishlist), .wishlist(.wishlist))
    }

    /// The account link lands in the Home tab, not the Account one: the account screen is reachable
    /// from Home's own stack, and this is the destination the app has always used.
    func test_accountLinkOpensTheAccountScreenInsideHome() {
        XCTAssertEqual(TabRoute(deepLinkType: .account), .home(.myAccount(.myAccount)))
    }

    /// The reason this PR exists: the whole Handle has to survive the trip to the Product Details
    /// page, separators included. `route` and `query` are carried by the link but not by the route —
    /// the page resolves the product from the Handle alone.
    func test_productDetailLinkCarriesTheWholeHandleToProductDetails() {
        let deepLink = DeepLink.LinkType.productDetail(
            handle: "women/dresses/red-midi-dress",
            route: "885035",
            query: ["sku": "12345"]
        )

        XCTAssertEqual(
            TabRoute(deepLinkType: deepLink),
            .shop(.productDetails(.productDetails(.deepLink(handle: "women/dresses/red-midi-dress"))))
        )
    }

    func test_productListLinkOpensTheListingWithItsCategoryAndSearch() {
        let deepLink = DeepLink.LinkType.productList(
            category: "women/dresses",
            query: "midi",
            urlParameters: ["colour": "red"]
        )

        XCTAssertEqual(
            TabRoute(deepLinkType: deepLink),
            .shop(.productListing(.productListing(.init(
                category: "women/dresses",
                searchText: "midi",
                urlQueryParameters: ["colour": "red"],
                mode: .listing
            ))))
        )
    }

    func test_webViewLinkOpensTheUrlInTheShopTab() throws {
        let url = try XCTUnwrap(URL(string: "https://www.alfie.com/some/marketing/page"))

        XCTAssertEqual(TabRoute(deepLinkType: .webView(url: url)), .shop(.web(url: url, title: "")))
    }

    /// An unrecognised link names no destination, so the app stays where it is rather than guessing.
    func test_unknownLinkHasNoDestination() {
        XCTAssertNil(TabRoute(deepLinkType: .unknown))
    }

    // MARK: - The hand-off

    /// The one thing the assertions above cannot see: that `navigate(for:)` passes the route on at
    /// all, and that a link naming no destination leaves the app where it stood. Only the tab is
    /// observable from here — which screen was pushed is the business of the tests above.
    func test_navigatingForwardsTheRouteToTheTabs() {
        let sut = AppFeatureViewModel(
            serviceProvider: MockServiceProvider(),
            log: Log.DummyLogger(),
            startupCompletionDelay: 0
        )
        XCTAssertEqual(sut.rootTabViewModel.selectedTab, .home)

        sut.navigate(for: .productDetail(handle: "women/dresses/red-midi-dress", route: nil, query: nil))
        XCTAssertEqual(sut.rootTabViewModel.selectedTab, .shop)

        sut.navigate(for: .unknown)
        XCTAssertEqual(sut.rootTabViewModel.selectedTab, .shop)
    }
}
