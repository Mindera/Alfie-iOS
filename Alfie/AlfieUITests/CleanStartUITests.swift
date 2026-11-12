import AccessibilityIdentifiers
import XCTest

final class CleanStartUITests: AlfieUITestCase {
    private let systemAlertTimeout: TimeInterval = 3

    func testLaunchShowsNoSystemAlert() {
        waitFor(app.otherElements[AccessibilityID.TabBar.home], "The app should land on its tabs")

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        XCTAssertFalse(
            springboard.alerts.firstMatch.waitForExistence(timeout: systemAlertTimeout),
            "A UI test launch should raise no system alert"
        )
    }

    func testASearchLeavesNoRecentSearchOnTheNextLaunch() {
        let search = SearchPage(app: app)

        XCTContext.runActivity(named: "Search in the first launch") { _ in
            search.open(timeout: timeout)
            search.submit("shirt")
            waitFor(search.resultsSearchBar, "Submitting should leave Search for the results")
        }

        XCTContext.runActivity(named: "The second launch has no recent search") { _ in
            app.terminate()
            app.launch()
            search.open(timeout: timeout)
            XCTAssertFalse(
                search.recentSearches.firstMatch.waitForExistence(timeout: timeout),
                "A UI test launch should start with no recent searches"
            )
        }
    }
}
