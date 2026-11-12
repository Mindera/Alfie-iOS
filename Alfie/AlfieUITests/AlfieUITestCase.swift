import XCTest

class AlfieUITestCase: XCTestCase {
    private(set) var app: XCUIApplication!
    let timeout: TimeInterval = 5

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = Self.makeApp()
        app.launch()
    }

    static func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["ALFIE_UI_TEST"] = "1"
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        return app
    }

    func waitFor(_ element: XCUIElement, _ message: String) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), message)
    }
}
