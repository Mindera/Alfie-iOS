import AccessibilityIdentifiers
import XCTest

final class AddToBagJourneyTests: AlfieUITestCase {
    /// `SeedAnchors.Products.default` and `SeedAnchors.Barcode.variantId`, mirrored until the UI
    /// test target links `TestSeed` (#255).
    private let defaultProductHandle = "alfie-oxford-shirt"
    private let inStockVariantId = "mock-variant-alfie-oxford-shirt-white-xs"
    private let writeTimeout: TimeInterval = 20

    func testAddToBagJourney() throws {
        let pdp = ProductDetailsPage(app: app)
        let bag = BagPage(app: app)

        XCTContext.runActivity(named: "Open the in-stock variant by deep link") { _ in
            waitFor(bag.tab, "The tab bar should be up before the deep link is opened")
            pdp.open(handle: defaultProductHandle, variantId: inStockVariantId)
            pdp.assertVisible()
        }

        XCTContext.runActivity(named: "Add it to the bag") { _ in
            waitFor(pdp.addToBagButton, "The PDP should show Add to Bag")
            XCTAssertTrue(pdp.addToBagButton.isEnabled, "The deep link should restore the in-stock variant")
            pdp.tapAddToBag()

            let snackbar = app.staticTexts[AccessibilityID.Snackbar.text]
            XCTAssertTrue(snackbar.waitForExistence(timeout: writeTimeout), "A Snackbar should confirm the add")
            XCTAssertEqual(snackbar.label, "Added to bag", "The add should succeed")
        }

        XCTContext.runActivity(named: "The Bag shows one line") { _ in
            bag.open()
            XCTAssertTrue(
                bag.lineItems.firstMatch.waitForExistence(timeout: writeTimeout),
                "The Bag should show the line just added"
            )
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
            XCTAssertTrue(
                bag.emptyState.waitForExistence(timeout: writeTimeout),
                "Removing the only line should show the empty state"
            )
            XCTAssertEqual(bag.lineItems.count, 0, "No line should remain after the removal")
        }
    }
}
