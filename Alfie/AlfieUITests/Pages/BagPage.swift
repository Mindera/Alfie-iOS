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

    /// Every *tappable* line currently rendered. A row is a `Button` — the whole row opens the
    /// line's product — so rows are `buttons`, and the suffix exclusion keeps a revealed Remove
    /// button, whose identifier is nested under the row's, from counting as a line.
    ///
    /// The narrowing is deliberate but not free: a line the BFF sent without a slug stays a plain
    /// container and is invisible here, so counts taken from this query are counts of openable
    /// rows. Every line of a real cart carries a slug — `CartIntegrationTests` asserts exactly
    /// that — so against a live BFF this is every line.
    var lineItems: XCUIElementQuery {
        app.buttons.matching(
            NSPredicate(
                format: "identifier BEGINSWITH %@ AND NOT identifier ENDSWITH %@",
                AccessibilityID.Bag.lineItemPrefix,
                AccessibilityID.Bag.lineItemRemoveButtonSuffix
            )
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

    /// Opens the line's product detail page. The whole row is the tap target.
    @discardableResult
    func tapLine(_ line: XCUIElement) -> Self {
        line.tap()
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
