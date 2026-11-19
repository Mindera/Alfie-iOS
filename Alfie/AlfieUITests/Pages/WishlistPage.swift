import AccessibilityIdentifiers
import XCTest

final class WishlistPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Elements

    var tab: XCUIElement {
        app.otherElements[AccessibilityID.TabBar.wishlist]
    }

    /// Item ids come from the BFF.
    var removeButtons: XCUIElementQuery {
        app.buttons.matching(
            identifierPrefix: AccessibilityID.Wishlist.itemPrefix,
            suffix: AccessibilityID.Wishlist.itemRemoveButtonSuffix
        )
    }

    var emptyState: XCUIElement {
        app.descendants(matching: .any)[AccessibilityID.Wishlist.emptyState]
    }

    // MARK: - Actions

    @discardableResult
    func open() -> Self {
        tab.tap()
        return self
    }

    @discardableResult
    func removeFirstItem() -> Self {
        removeButtons.firstMatch.tap()
        return self
    }
}
