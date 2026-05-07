import XCTest

// MARK: - ProductListingPage
//
// Page Object for the Product Listing screen. Wraps `XCUIApplication` queries
// behind named accessors so UI tests stay readable and survive UI refactors.
//
// Identifier values mirror `AccessibilityID.ProductListing.*` in the
// `AccessibilityIdentifiers` SPM module. Once that module is linked to the
// `AlfieUITests` target in Xcode, replace the literals below with
// `AccessibilityID.ProductListing.*` and `import AccessibilityIdentifiers`.
final class ProductListingPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Elements

    var filterButton: XCUIElement {
        app.buttons["productListing.filter.button"]
    }

    var resultsLabel: XCUIElement {
        app.staticTexts["productListing.results.label"]
    }

    var listStyleGridButton: XCUIElement {
        app.buttons["productListing.listStyle.grid.button"]
    }

    var listStyleListButton: XCUIElement {
        app.buttons["productListing.listStyle.list.button"]
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
