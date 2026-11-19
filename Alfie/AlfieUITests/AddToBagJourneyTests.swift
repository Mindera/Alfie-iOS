import TestSeed
import XCTest

final class AddToBagJourneyTests: AlfieUITestCase {
    func testAddToBagJourney() throws {
        let pdp = ProductDetailsPage(app: app)
        let bag = BagPage(app: app)
        let snackbar = SnackbarPage(app: app)

        XCTContext.runActivity(named: "Open the in-stock variant by deep link") { _ in
            waitFor(bag.tab, "The tab bar should be up before the deep link is opened")
            pdp.open(
                handle: SeedAnchors.InStockVariants.productSlug,
                variantId: SeedAnchors.InStockVariants.variantIds[0]
            )
            pdp.assertVisible()
        }

        XCTContext.runActivity(named: "Add it to the bag") { _ in
            waitFor(pdp.addToBagButton, "The PDP should show Add to Bag")
            XCTAssertTrue(pdp.addToBagButton.isEnabled, "The deep link should restore the in-stock variant")
            pdp.tapAddToBag()

            waitFor(snackbar.text, timeout: .bffWrite, "A Snackbar should confirm the add")
            XCTAssertEqual(snackbar.text.label, "Added to bag", "The add should succeed")
        }

        XCTContext.runActivity(named: "The Bag shows one line") { _ in
            bag.open()
            waitFor(bag.lineItems.firstMatch, timeout: .bffWrite, "The Bag should show the line just added")
            XCTAssertEqual(bag.lineItems.count, 1, "The Bag should hold exactly the line just added")
        }

        XCTContext.runActivity(named: "The line opens its product, and back returns to the Bag") { _ in
            bag.tapLine(bag.lineItems.firstMatch)
            pdp.assertVisible()
            pdp.tapBack()
            waitFor(bag.lineItems.firstMatch, "Back from the PDP should return to the Bag")
            XCTAssertEqual(bag.lineItems.count, 1, "Coming back from the product should leave the Bag as it was")
        }

        XCTContext.runActivity(named: "Swiping the line and tapping Remove empties the Bag") { _ in
            bag.removeLine(bag.lineItems.firstMatch)
            waitFor(bag.emptyState, timeout: .bffWrite, "Removing the only line should show the empty state")
            XCTAssertEqual(bag.lineItems.count, 0, "No line should remain after the removal")
        }
    }
}
