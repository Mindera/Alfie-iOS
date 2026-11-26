import XCTest

final class BrowseJourneyTests: AlfieUITestCase {
    /// `MainMenu.graphql` requests three levels of items, so the menu cannot nest deeper than that.
    private let menuDepthLimit = 3

    func testBrowseJourney() throws {
        let shop = ShopPage(app: app)
        let listing = ProductListingPage(app: app)
        let pdp = ProductDetailsPage(app: app)

        XCTContext.runActivity(named: "Open the Shop tab") { _ in
            waitFor(shop.tab, "The tab bar should show Shop")
            shop.open()
        }

        XCTContext.runActivity(named: "Follow the first category down to a leaf") { _ in
            for _ in 0 ..< menuDepthLimit where !listing.filterButton.exists {
                waitFor(shop.firstCategory, timeout: .bffRead, "Shop should list at least one category")
                let tappedTitle = shop.firstCategory.label
                shop.tapFirstCategory()
                waitForListingOrSubCategories(of: tappedTitle, shop: shop, listing: listing)
            }
            listing.assertVisible()
        }

        XCTContext.runActivity(named: "The first product opens its product page") { _ in
            waitFor(listing.productCards.firstMatch, timeout: .bffRead, "The leaf category should list a product")
            listing.tapFirstProduct()
            pdp.assertVisible(timeout: .bffRead)
            XCTAssertFalse(pdp.productName.label.isEmpty, "The product page should show a non-empty name")
        }
    }

    /// A parent category pushes the same list under the same identifier, so only a changed first
    /// title tells a sub-list from the list that was tapped. A sub-list that repeats its parent's title
    /// times out here, and the caller's loop carries on.
    private func waitForListingOrSubCategories(of tappedTitle: String, shop: ShopPage, listing: ProductListingPage) {
        let settled = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in
                listing.filterButton.exists
                    || (shop.firstCategory.exists && shop.firstCategory.label != tappedTitle)
            },
            object: nil
        )
        _ = XCTWaiter.wait(for: [settled], timeout: .bffRead)
    }
}
