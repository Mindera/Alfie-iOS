import AccessibilityIdentifiers
import XCTest

final class SnackbarPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Elements

    var text: XCUIElement {
        app.staticTexts[AccessibilityID.Snackbar.text]
    }
}
