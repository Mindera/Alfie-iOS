import AccessibilityIdentifiers
import XCTest

// MARK: - ProductDetailsPage
//
// Page Object for the Product Details (PDP) screen. Wraps `XCUIApplication`
// queries behind named accessors so UI tests stay readable.
final class ProductDetailsPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Elements

    var titleHeader: XCUIElement {
        app.staticTexts[AccessibilityID.ProductDetails.titleHeader]
    }

    var productImage: XCUIElement {
        // The media carousel is a container view, not an XCUIElement image — queried as otherElements.
        app.otherElements[AccessibilityID.ProductDetails.productImage]
    }

    var productTitle: XCUIElement {
        app.staticTexts[AccessibilityID.ProductDetails.productTitle]
    }

    var productDescription: XCUIElement {
        app.staticTexts[AccessibilityID.ProductDetails.productDescription]
    }

    var colourSelector: XCUIElement {
        app.otherElements[AccessibilityID.ProductDetails.colourSelector]
    }

    var sizeSelector: XCUIElement {
        app.otherElements[AccessibilityID.ProductDetails.sizeSelector]
    }

    var addToBagButton: XCUIElement {
        app.buttons[AccessibilityID.ProductDetails.addToBagButton]
    }

    var addToWishlistButton: XCUIElement {
        app.buttons[AccessibilityID.ProductDetails.addToWishlistButton]
    }

    // MARK: - Actions

    @discardableResult
    func tapAddToBag() -> Self {
        addToBagButton.tap()
        return self
    }

    @discardableResult
    func tapAddToWishlist() -> Self {
        addToWishlistButton.tap()
        return self
    }

    @discardableResult
    func openColourSheet() -> Self {
        colourSelector.tap()
        return self
    }

    @discardableResult
    func openSizeSheet() -> Self {
        sizeSelector.tap()
        return self
    }

    // MARK: - Assertions

    func assertVisible(timeout: TimeInterval = 5) {
        XCTAssertTrue(
            productTitle.waitForExistence(timeout: timeout),
            "Product Details product title should be visible"
        )
    }
}
