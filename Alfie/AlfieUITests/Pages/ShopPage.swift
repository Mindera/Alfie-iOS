import AccessibilityIdentifiers
import XCTest

final class ShopPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Elements

    var tab: XCUIElement {
        app.otherElements[AccessibilityID.TabBar.shop]
    }

    /// Loaded categories only: placeholder rows carry no identifier.
    var categories: XCUIElementQuery {
        app.buttons.matching(identifier: AccessibilityID.Categories.item)
    }

    var firstCategory: XCUIElement {
        categories.firstMatch
    }

    // MARK: - Actions

    @discardableResult
    func open() -> Self {
        tab.tap()
        return self
    }

    @discardableResult
    func tapFirstCategory() -> Self {
        firstCategory.tap()
        return self
    }
}
