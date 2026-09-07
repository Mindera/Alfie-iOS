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
        app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", AccessibilityID.Bag.lineItemPrefix)
        )
    }

    var subtotal: XCUIElement {
        app.otherElements[AccessibilityID.Bag.subtotal]
    }

    var grandTotal: XCUIElement {
        app.otherElements[AccessibilityID.Bag.grandTotal]
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
        let lineId = String(line.identifier.dropFirst(AccessibilityID.Bag.lineItemPrefix.count))
        line.swipeLeft()
        let remove = app.buttons[AccessibilityID.Bag.lineItemRemoveButton(id: lineId)]
        XCTAssertTrue(remove.waitForExistence(timeout: 5), "Swiping a bag row should reveal Remove")
        remove.tap()
        return self
    }
}
