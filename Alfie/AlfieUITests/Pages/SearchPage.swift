import AccessibilityIdentifiers
import XCTest

final class SearchPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Elements

    var entryButton: XCUIElement {
        app.buttons[AccessibilityID.Home.searchInput]
    }

    var input: XCUIElement {
        app.textFields[AccessibilityID.SearchBar.input]
    }

    var moreProductsButton: XCUIElement {
        app.buttons[AccessibilityID.Search.moreProductsButton]
    }

    var noResults: XCUIElement {
        app.descendants(matching: .any)[AccessibilityID.Search.noResults]
    }

    // MARK: - Actions

    @discardableResult
    func open() -> Self {
        entryButton.tap()
        return self
    }

    @discardableResult
    func type(_ term: String) -> Self {
        input.typeText(term)
        return self
    }

    @discardableResult
    func submit() -> Self {
        input.typeText("\n")
        return self
    }
}
