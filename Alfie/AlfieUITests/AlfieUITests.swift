import AccessibilityIdentifiers
import XCTest

final class AlfieUITests: AlfieUITestCase {
    /// A cart write is a real round trip to the BFF, so it gets longer than a local UI transition.
    private let writeTimeout: TimeInterval = 20
    /// `MainMenu.graphql` requests three levels of items, so the menu cannot nest deeper than that.
    private let menuDepthLimit = 3

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

        try super.tearDownWithError()
    }

    // MARK: - Tests

    /// End-to-end journey: Home → Shop → first category → first product → add to bag →
    /// success Snackbar.
    ///
    /// …then Bag tab → the line is there with its total → tap it → its PDP opens → back → swipe →
    /// Remove → it is gone.
    ///
    /// Needs a reachable BFF: both the add and the removal are real round trips, not local
    /// appends. The bag half was dropped by #116, when the write moved to the server cart while
    /// the Bag screen still read local storage; #117 pointed the screen at the cart and restores
    /// it here.
    ///
    /// Locators outside PDP still use raw identifier strings
    /// (`shop-tab`, `category-item`, `product-image`, `bag-tab`,
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

        XCTContext.runActivity(named: "Follow the Shop menu down to a product listing") { _ in
            // Shop reached the PDP through a Brands segment until #104 replaced the segmented
            // control with a plain category list read from the BFF menu. A menu item that has
            // children drills into a sub-list instead of opening a listing — see
            // `CategoriesViewModel.didSelectCategory` — and that sub-list is the same
            // `CategoriesView` under the same identifier. So follow the first item down until
            // products appear, rather than assuming the first entry is a leaf and failing on the
            // shape of the store's menu instead of on a defect.
            for _ in 0 ..< menuDepthLimit {
                let firstCategory = app.buttons.matching(identifier: "category-item").element(boundBy: 0)
                waitFor(firstCategory, "At least one category should be available")
                firstCategory.tap()

                let firstProduct = app.images.matching(identifier: "product-image").element(boundBy: 0)
                if firstProduct.waitForExistence(timeout: timeout) {
                    return
                }
            }
            XCTFail("Followed the menu \(menuDepthLimit) levels down without reaching a listing")
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

        XCTContext.runActivity(named: "The bag shows the line that was added, with its total") { _ in
            bag.open()
            XCTAssertTrue(
                bag.lineItems.element(boundBy: 0).waitForExistence(timeout: writeTimeout),
                "The bag should render the line just added — check a BFF is reachable"
            )
            lineCountAfterAdd = bag.lineItems.count
            XCTAssertGreaterThan(lineCountAfterAdd, 0, "The bag should hold at least the line just added")
            XCTAssertTrue(bag.grandTotal.exists, "A bag with lines shows a total")
            XCTAssertTrue(bag.continueButton.exists, "A bag with lines shows Continue")
        }

        XCTContext.runActivity(named: "Tapping a line opens its product, and back returns to the bag") { _ in
            // The row tapped is whichever line is first, which need not be the one just added — the
            // cart id persists across launches. That the PDP opens at all is the claim; which
            // product it lands on is the view model's business and is pinned by its unit tests.
            bag.tapLine(bag.lineItems.element(boundBy: 0))
            pdp.assertVisible(timeout: timeout)

            pdp.tapBack()

            XCTAssertTrue(
                bag.lineItems.element(boundBy: 0).waitForExistence(timeout: timeout),
                "Back from the PDP should return to the bag"
            )
            XCTAssertEqual(
                bag.lineItems.count, lineCountAfterAdd,
                "Coming back from a product must leave the bag exactly as it was"
            )
        }

        XCTContext.runActivity(named: "Swiping a line and tapping Remove drops it on the server") { _ in
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
                Self.makeApp().launch()
            }
        }
    }
}
