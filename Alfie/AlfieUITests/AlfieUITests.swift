import AccessibilityIdentifiers
import XCTest

final class AlfieUITests: XCTestCase {
    private var app: XCUIApplication!
    private let timeout: TimeInterval = 5
    /// A cart write is a real round trip to the BFF, so it gets longer than a local UI transition.
    private let writeTimeout: TimeInterval = 20

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Attach screenshot + accessibility hierarchy on every test; both use
        // `.deleteOnSuccess`, so Xcode prunes them on green runs and keeps
        // them only when the test fails. The AX dump is what Xcode never
        // captures on its own and is usually what you need to diagnose
        // "element not found" failures.
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = "Final screen — \(name)"
        screenshot.lifetime = .deleteOnSuccess
        add(screenshot)

        let hierarchy = XCTAttachment(string: app.debugDescription)
        hierarchy.name = "Accessibility hierarchy — \(name)"
        hierarchy.lifetime = .deleteOnSuccess
        add(hierarchy)
    }

    private func waitFor(_ element: XCUIElement, _ message: String) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), message)
    }

    // MARK: - Tests

    /// End-to-end journey: Home → Shop → Brands → first brand → first product → add to bag →
    /// success Snackbar.
    ///
    /// …then Bag tab → the line is there with totals → swipe → Remove → it is gone.
    ///
    /// Needs a reachable BFF: both the add and the removal are real round trips, not local
    /// appends. The bag half was dropped by #116, when the write moved to the server cart while
    /// the Bag screen still read local storage; #117 pointed the screen at the cart and restores
    /// it here.
    ///
    /// Locators outside PDP and Brands still use raw identifier strings
    /// (`shop-tab`, `segmented-option-brands`, `product-image`, `bag-tab`,
    /// `product-name`). Migrating the remainder into the
    /// `AccessibilityIdentifiers` module is tracked as a separate follow-up.
    func testAddToBagFullFlow() throws {
        let pdp = ProductDetailsPage(app: app)
        var expectedProductName = ""

        XCTContext.runActivity(named: "Open the Shop tab") { _ in
            let shopTab = app.otherElements[AccessibilityID.TabBar.shop]
            waitFor(shopTab, "Shop tab should exist")
            shopTab.tap()
        }

        XCTContext.runActivity(named: "Select the Brands segment") { _ in
            let brandsSegment = app.buttons["segmented-option-brands"]
            waitFor(brandsSegment, "Brands segment should exist")
            brandsSegment.tap()
        }

        XCTContext.runActivity(named: "Open the first available brand") { _ in
            let firstBrand = app.buttons.matching(identifier: AccessibilityID.Brands.item).element(boundBy: 0)
            waitFor(firstBrand, "At least one brand should be available")
            firstBrand.tap()
        }

        XCTContext.runActivity(named: "Open the first product in the listing") { _ in
            let firstProduct = app.images.matching(identifier: "product-image").element(boundBy: 0)
            waitFor(firstProduct, "At least one product should be available")
            firstProduct.tap()
        }

        XCTContext.runActivity(named: "PDP is visible, capture product name") { _ in
            pdp.assertVisible(timeout: timeout)
            let name = pdp.productName.label
            XCTAssertFalse(name.isEmpty, "Product name should be non-empty on PDP")
            expectedProductName = name
        }

        XCTContext.runActivity(named: "Add to bag") { _ in
            waitFor(pdp.addToBagButton, "Add to bag button should exist")
            XCTAssertTrue(pdp.addToBagButton.isEnabled, "Add to bag should be enabled for a purchasable variant")
            pdp.tapAddToBag()
        }

        XCTContext.runActivity(named: "The write is confirmed, on the PDP") { _ in
            // The cart round trip has to land, so this waits longer than the standard timeout.
            let snackbar = app.staticTexts[AccessibilityID.Snackbar.text]
            XCTAssertTrue(
                snackbar.waitForExistence(timeout: writeTimeout),
                "A Snackbar should confirm the add — check a BFF is reachable at the dev endpoint"
            )
            XCTAssertEqual(snackbar.label, "Added to bag", "The add should succeed, not fail")
        }

        XCTContext.runActivity(named: "Adding does not navigate away from the PDP") { _ in
            XCTAssertEqual(
                pdp.productName.label,
                expectedProductName,
                "The PDP should still be showing the product that was added"
            )
        }

        let bag = BagPage(app: app)
        var lineCountAfterAdd = 0

        XCTContext.runActivity(named: "The bag shows the line that was added, with totals") { _ in
            bag.open()
            XCTAssertTrue(
                bag.lineItems.element(boundBy: 0).waitForExistence(timeout: writeTimeout),
                "The bag should render the line just added — check a BFF is reachable"
            )
            lineCountAfterAdd = bag.lineItems.count
            XCTAssertGreaterThan(lineCountAfterAdd, 0, "The bag should hold at least the line just added")
            XCTAssertTrue(bag.subtotal.exists, "A bag with lines shows a subtotal")
            XCTAssertTrue(bag.grandTotal.exists, "A bag with lines shows a total")
        }

        XCTContext.runActivity(named: "Swiping a line and tapping Remove drops it on the server") { _ in
            // The cart id persists across launches, so the bag may hold lines from earlier runs.
            // Asserting the count fell by one is stable where asserting it reached zero is not.
            bag.removeLine(bag.lineItems.element(boundBy: 0))

            let expected = lineCountAfterAdd - 1
            let dropped = NSPredicate(format: "count == %d", expected)
            expectation(for: dropped, evaluatedWith: bag.lineItems)
            waitForExpectations(timeout: writeTimeout) { error in
                XCTAssertNil(error, "Removing a line should leave \(expected) — the removal is a server write")
            }
        }
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
