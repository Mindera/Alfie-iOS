import AccessibilityIdentifiers
import XCTest

// MARK: - BagPage
//
// Page Object for the Bag screen. Rows are keyed on the server-assigned line id, so they are
// matched by identifier prefix rather than by a fixed id the test cannot know in advance.
final class BagPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Elements

    var tab: XCUIElement {
        app.otherElements[AccessibilityID.TabBar.bag]
    }

    /// Every line currently rendered. `BagLineRow` is an accessibility container, so the rows are
    /// `otherElements`.
    var lineItems: XCUIElementQuery {
        app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH %@", "bag.lineItem."))
    }

    var emptyState: XCUIElement {
        app.otherElements[AccessibilityID.Bag.emptyState]
    }

    var subtotal: XCUIElement {
        app.otherElements[AccessibilityID.Bag.subtotal]
    }

    var grandTotal: XCUIElement {
        app.otherElements[AccessibilityID.Bag.grandTotal]
    }

    var errorRetryButton: XCUIElement {
        app.buttons[AccessibilityID.Bag.errorRetryButton]
    }

    // MARK: - Actions

    @discardableResult
    func open() -> Self {
        tab.tap()
        return self
    }

    /// Swipes the row open and taps Remove. Full swipe is disabled on the row, so the tap is
    /// required rather than optional.
    @discardableResult
    func removeLine(_ line: XCUIElement) -> Self {
        let lineId = String(line.identifier.dropFirst("bag.lineItem.".count))
        line.swipeLeft()
        let remove = app.buttons[AccessibilityID.Bag.lineItemRemoveButton(id: lineId)]
        XCTAssertTrue(remove.waitForExistence(timeout: 5), "Swiping a bag row should reveal Remove")
        remove.tap()
        return self
    }

    // MARK: - Assertions

    func assertVisible(timeout: TimeInterval = 5) {
        XCTAssertTrue(
            lineItems.element(boundBy: 0).waitForExistence(timeout: timeout) || emptyState.exists,
            "The Bag should show either at least one line or the empty state"
        )
    }
}
