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

    /// One per item: item ids come from the BFF, so they are matched by prefix and suffix.
    var removeButtons: XCUIElementQuery {
        app.buttons.matching(
            NSPredicate(
                format: "identifier BEGINSWITH %@ AND identifier ENDSWITH %@",
                AccessibilityID.Wishlist.itemPrefix,
                AccessibilityID.Wishlist.removeButtonSuffix
            )
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
