import AccessibilityIdentifiers
import TestSeed
import XCTest

final class WishlistJourneyTests: AlfieUITestCase {
    func testWishlistJourney() throws {
        let pdp = ProductDetailsPage(app: app)
        let wishlist = WishlistPage(app: app)

        XCTContext.runActivity(named: "Open the product by deep link") { _ in
            waitFor(wishlist.tab, "The bundled local config should enable the Wishlist tab")
            pdp.open(handle: SeedAnchors.Products.default)
            pdp.assertVisible(timeout: .deepLinkRelaunch)
        }

        XCTContext.runActivity(named: "Add it to the wishlist") { _ in
            waitFor(pdp.addToWishlistButton, "The PDP should show the wishlist heart")
            pdp.tapAddToWishlist()
            waitFor(
                pdp.removeFromWishlistButton,
                "The heart should switch to remove once the product is in the wishlist"
            )
        }

        XCTContext.runActivity(named: "The Wishlist tab shows one item") { _ in
            wishlist.open()
            waitFor(wishlist.removeButtons.firstMatch, "The Wishlist should show the product just added")
            XCTAssertEqual(wishlist.removeButtons.count, 1, "The Wishlist should hold exactly the product just added")
            XCTAssertTrue(
                wishlist.removeButtons.firstMatch.identifier.contains(SeedAnchors.Products.default),
                "The Wishlist item should be the product just added"
            )
        }

        XCTContext.runActivity(named: "Removing it leaves the empty state") { _ in
            wishlist.removeFirstItem()
            waitFor(wishlist.emptyState, "Removing the only item should show the empty state")
            XCTAssertEqual(wishlist.removeButtons.count, 0, "No item should remain after the removal")
        }
    }
}
