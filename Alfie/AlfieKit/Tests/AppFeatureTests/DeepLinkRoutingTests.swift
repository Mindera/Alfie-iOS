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
/// screen. The `navigate_for_…` tests cover the hand-off itself.
final class DeepLinkRoutingTests: XCTestCase {
    func test_tab_route_for_tab_link_opens_the_tab_at_its_root() {
        let cases: [(link: DeepLink.LinkType, expected: TabRoute)] = [
            (.home, .home(.home)),
            (.shop(route: nil), .shop(.categorySelector)),
            (.bag, .bag(.bag)),
            (.wishlist, .wishlist(.wishlist)),
        ]

        for testCase in cases {
            let route = TabRoute(deepLinkType: testCase.link)

            XCTAssertEqual(route, testCase.expected, "route for \(testCase.link)")
        }
    }

    /// The account link lands in the Home tab, not the Account one: the account screen is reachable
    /// from Home's own stack, and this is the destination the app has always used.
    func test_tab_route_for_account_link_opens_the_account_screen_inside_home() {
        XCTAssertEqual(TabRoute(deepLinkType: .account), .home(.myAccount(.myAccount)))
    }

    /// The whole Handle has to survive the trip to the Product Details page, separators included,
    /// and so does the SKU that picks the Variant the shopper arrives on.
    func test_tab_route_for_product_detail_link_carries_the_whole_handle_and_sku() {
        let deepLink = DeepLink.LinkType.productDetail(
            handle: "women/dresses/red-midi-dress",
            route: "885035",
            query: ["sku": "12345"]
        )

        XCTAssertEqual(
            TabRoute(deepLinkType: deepLink),
            .shop(.productDetails(.productDetails(.deepLink(handle: "women/dresses/red-midi-dress", sku: "12345"))))
        )
    }

    func test_tab_route_for_product_detail_link_carries_the_variant_id() {
        let deepLink = DeepLink.LinkType.productDetail(handle: "8", route: nil, query: ["variantId": "22"])

        XCTAssertEqual(
            TabRoute(deepLinkType: deepLink),
            .shop(.productDetails(.productDetails(.deepLink(handle: "8", variantId: "22"))))
        )
    }

    func test_tab_route_for_product_detail_link_without_sku_opens_the_default_variant() {
        let deepLink = DeepLink.LinkType.productDetail(handle: "red-midi-dress", route: nil, query: nil)

        XCTAssertEqual(
            TabRoute(deepLinkType: deepLink),
            .shop(.productDetails(.productDetails(.deepLink(handle: "red-midi-dress"))))
        )
    }

    func test_tab_route_for_product_list_link_keeps_its_category_and_search() {
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

    func test_tab_route_for_web_view_link_opens_the_url_in_the_shop_tab() throws {
        let url = try XCTUnwrap(URL(string: "https://www.alfie.com/some/marketing/page"))

        XCTAssertEqual(TabRoute(deepLinkType: .webView(url: url)), .shop(.web(url: url, title: "")))
    }

    /// An unrecognised link names no destination, so the app stays where it is rather than guessing.
    func test_tab_route_for_unknown_link_has_no_destination() {
        XCTAssertNil(TabRoute(deepLinkType: .unknown))
    }

    // MARK: - The hand-off

    /// The one thing the assertions above cannot see: that `navigate(for:)` passes the route on at
    /// all. Only the tab is observable from here — which screen was pushed is the business of the
    /// tests above.
    func test_navigate_for_product_detail_link_selects_the_shop_tab() {
        let sut = makeSUT()

        sut.navigate(for: .productDetail(handle: "women/dresses/red-midi-dress", route: nil, query: nil))

        XCTAssertEqual(sut.rootTabViewModel.selectedTab, .shop)
    }

    /// Starts away from the default tab, so a link naming no destination is seen to leave the app
    /// where it stood rather than resetting it to Home.
    func test_navigate_for_unknown_link_after_leaving_home_keeps_the_current_tab() {
        let sut = makeSUT()
        sut.navigate(for: .productDetail(handle: "women/dresses/red-midi-dress", route: nil, query: nil))

        sut.navigate(for: .unknown)

        XCTAssertEqual(sut.rootTabViewModel.selectedTab, .shop)
    }

    // MARK: - Helpers

    private func makeSUT() -> AppFeatureViewModel {
        AppFeatureViewModel(
            serviceProvider: MockServiceProvider(),
            log: Log.DummyLogger(),
            startupCompletionDelay: 0
        )
    }
}
