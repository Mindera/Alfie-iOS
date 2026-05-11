import AccessibilityIdentifiers
import XCTest

final class AlfieUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Attach a final screenshot to the test report. With `.deleteOnSuccess`, the
        // attachment is kept only when the test fails — giving us a visual snapshot
        // of the screen state at the moment things went wrong, with no noise on green runs.
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Final screen — \(name)"
        attachment.lifetime = .deleteOnSuccess
        add(attachment)
    }

    private let defaultTimeout: TimeInterval = 5

    /// Waits for an element to exist and fails the test with `message` if it does not appear in time.
    private func waitFor(_ element: XCUIElement, _ message: String, timeout: TimeInterval? = nil) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout ?? defaultTimeout), message)
    }

    func testAddToBagFullFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // 1. Switch to the Shop tab
        let shopTab = app.otherElements["shop-tab"]
        waitFor(shopTab, "Shop tab should exist")
        shopTab.tap()

        // 2. Select the Brands segment within Shop
        let brandsSegment = app.buttons["segmented-option-brands"]
        waitFor(brandsSegment, "Brands segment should exist")
        brandsSegment.tap()

        // 3. Tap the first available brand (avoid coupling the test to specific data)
        let firstBrand = app.buttons.matching(identifier: "brand-item").element(boundBy: 0)
        waitFor(firstBrand, "At least one brand should be available")
        firstBrand.tap()

        // 4. Open the first product in the listing
        let firstProduct = app.images.matching(identifier: "product-image").element(boundBy: 0)
        waitFor(firstProduct, "At least one product should be available")
        firstProduct.tap()

        // 5. Capture the product name shown on the PDP, then add to bag
        let productNameOnPDP = app.staticTexts[AccessibilityID.ProductDetails.productTitle]
        waitFor(productNameOnPDP, "Product name should be visible on PDP")
        let expectedProductName = productNameOnPDP.label

        let addToBagButton = app.buttons[AccessibilityID.ProductDetails.addToBagButton]
        waitFor(addToBagButton, "Add to bag button should exist")
        addToBagButton.tap()

        // 6. Pop back from PDP so the tab bar becomes visible again.
        let backButton = app.navigationBars.buttons.firstMatch
        waitFor(backButton, "Back button should exist on PDP")
        backButton.tap()

        // 7. Switch to the Bag tab
        let bagTab = app.otherElements["bag-tab"]
        waitFor(bagTab, "Bag tab should exist")
        bagTab.tap()

        // 7. Verify the product in the bag matches the one we added
        let productNameInBag = app.staticTexts.matching(identifier: "product-name").firstMatch
        waitFor(productNameInBag, "Product name should be visible in bag")
        XCTAssertEqual(
            productNameInBag.label,
            expectedProductName,
            "Product in bag should match the product that was added"
        )
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
