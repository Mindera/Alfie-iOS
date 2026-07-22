import AccessibilityIdentifiers
import XCTest

final class AlfieUITests: XCTestCase {
    private var app: XCUIApplication!
    private let timeout: TimeInterval = 5

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

    /// End-to-end journey: Home → Shop → Brands → first brand → first product → add to bag → verify in bag.
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
            let name = pdp.productTitle.label
            XCTAssertFalse(name.isEmpty, "Product title should be non-empty on PDP")
            expectedProductName = name
        }

        XCTContext.runActivity(named: "Add to bag") { _ in
            waitFor(pdp.addToBagButton, "Add to bag button should exist")
            pdp.tapAddToBag()
        }

        XCTContext.runActivity(named: "Pop back from PDP") { _ in
            let backButton = app.navigationBars.buttons.firstMatch
            waitFor(backButton, "Back button should exist on PDP")
            backButton.tap()
        }

        XCTContext.runActivity(named: "Open the Bag tab") { _ in
            let bagTab = app.otherElements[AccessibilityID.TabBar.bag]
            waitFor(bagTab, "Bag tab should exist")
            bagTab.tap()
        }

        XCTContext.runActivity(named: "Product in bag matches the product added") { _ in
            let productNameInBag = app.staticTexts.matching(identifier: "product-name").firstMatch
            waitFor(productNameInBag, "Product name should be visible in bag")
            XCTAssertEqual(
                productNameInBag.label,
                expectedProductName,
                "Product in bag should match the product that was added"
            )
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
