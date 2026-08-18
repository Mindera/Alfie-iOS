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

    var brandName: XCUIElement {
        app.staticTexts[AccessibilityID.ProductDetails.brandName]
    }

    var productName: XCUIElement {
        app.staticTexts[AccessibilityID.ProductDetails.productName]
    }

    var colourSummary: XCUIElement {
        app.buttons[AccessibilityID.ProductDetails.colourSummary]
    }

    var productDescription: XCUIElement {
        app.staticTexts[AccessibilityID.ProductDetails.productDescription]
    }

    /// The inline colour card grid. Absent for single-colour products and for a long colour run,
    /// which uses `colourSummary` or `colourSheetRow` instead.
    var colourSelector: XCUIElement {
        app.otherElements[AccessibilityID.ProductDetails.colourSelector]
    }

    /// Opens the colour sheet for a long colour run that has no selection yet — the one state where
    /// `colourSummary` has no swatch to draw.
    var colourSheetRow: XCUIElement {
        app.buttons[AccessibilityID.ProductDetails.colourSheetRow]
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

    /// The sheet opens from the summary, never from `colourSelector` — tapping that picks a colour.
    /// Only rendered for multi-colour products, so callers must check `exists` first.
    @discardableResult
    func tapColourSummary() -> Self {
        colourSummary.tap()
        return self
    }

    // MARK: - Assertions

    func assertVisible(timeout: TimeInterval = 5) {
        XCTAssertTrue(
            productName.waitForExistence(timeout: timeout),
            "Product Details product name should be visible"
        )
        // The brand line is deliberately NOT asserted here. It is omitted for a product with no
        // brand, so any test that lands on such a product would fail on data rather than on a
        // defect — and no timeout fixes that. Its shown/hidden behaviour is pinned instead by the
        // two ProductDetailsView snapshots, which control the fixture.
    }
}
