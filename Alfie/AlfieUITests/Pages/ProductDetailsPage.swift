import XCTest

// MARK: - ProductDetailsPage
//
// Page Object for the Product Details (PDP) screen. Wraps `XCUIApplication`
// queries behind named accessors so UI tests stay readable.
//
// Identifier values mirror `AccessibilityID.ProductDetails.*` in the
// `AccessibilityIdentifiers` SPM module. Once that module is linked to the
// `AlfieUITests` target in Xcode, replace the literals below with
// `AccessibilityID.ProductDetails.*` and `import AccessibilityIdentifiers`.
final class ProductDetailsPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Elements

    var titleHeader: XCUIElement {
        app.staticTexts["productDetails.title.header"]
    }

    var productImage: XCUIElement {
        app.otherElements["productDetails.product.image"]
    }

    var productTitle: XCUIElement {
        app.staticTexts["productDetails.product.title"]
    }

    var productDescription: XCUIElement {
        app.staticTexts["productDetails.description.text"]
    }

    var colourSelector: XCUIElement {
        app.otherElements["productDetails.colour.selector"]
    }

    var sizeSelector: XCUIElement {
        app.otherElements["productDetails.size.selector"]
    }

    var addToBagButton: XCUIElement {
        app.buttons["productDetails.addToBag.button"]
    }

    var addToWishlistButton: XCUIElement {
        app.buttons["productDetails.addToWishlist.button"]
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
