import AccessibilityIdentifiers
import XCTest

// MARK: - ProductListingPage
//
// Page Object for the Product Listing screen. Wraps `XCUIApplication` queries
// behind named accessors so UI tests stay readable and survive UI refactors.
final class ProductListingPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Elements

    var filterButton: XCUIElement {
        app.buttons[AccessibilityID.ProductListing.filterButton]
    }

    var resultsLabel: XCUIElement {
        app.staticTexts[AccessibilityID.ProductListing.resultsLabel]
    }

    var listStyleGridButton: XCUIElement {
        app.buttons[AccessibilityID.ProductListing.listStyleGridButton]
    }

    var listStyleListButton: XCUIElement {
        app.buttons[AccessibilityID.ProductListing.listStyleListButton]
    }

    // MARK: - Actions

    @discardableResult
    func tapFilter() -> Self {
        filterButton.tap()
        return self
    }

    @discardableResult
    func selectGridStyle() -> Self {
        listStyleGridButton.tap()
        return self
    }

    @discardableResult
    func selectListStyle() -> Self {
        listStyleListButton.tap()
        return self
    }

    // MARK: - Assertions

    func assertVisible(timeout: TimeInterval = 5) {
        XCTAssertTrue(
            filterButton.waitForExistence(timeout: timeout),
            "Product Listing filter button should be visible"
        )
    }
}
