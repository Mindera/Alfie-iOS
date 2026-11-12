import AccessibilityIdentifiers
import XCTest

final class SearchPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    var entryButton: XCUIElement {
        app.buttons[AccessibilityID.Home.searchInput]
    }

    var input: XCUIElement {
        app.textFields[AccessibilityID.Search.input]
    }

    var recentSearches: XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: AccessibilityID.Search.recentSearchRow)
    }

    var resultsSearchBar: XCUIElement {
        app.buttons[AccessibilityID.ProductListing.searchBarButton]
    }

    func open(timeout: TimeInterval = 5) {
        XCTAssertTrue(entryButton.waitForExistence(timeout: timeout), "Home should show the search bar")
        entryButton.tap()
        XCTAssertTrue(input.waitForExistence(timeout: timeout), "Search should open with its input")
    }

    func submit(_ term: String) {
        input.tap()
        input.typeText(term + "\n")
    }
}
