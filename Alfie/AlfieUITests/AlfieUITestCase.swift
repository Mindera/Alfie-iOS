import AccessibilityIdentifiers
import XCTest

class AlfieUITestCase: XCTestCase {
    private(set) var app: XCUIApplication!
    let timeout: TimeInterval = 5

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = Self.makeApp()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    static func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment[UITestSignal.environmentKey] = UITestSignal.enabledValue
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        return app
    }

    func waitFor(
        _ element: XCUIElement,
        timeout: TimeInterval? = nil,
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            element.waitForExistence(timeout: timeout ?? self.timeout),
            message,
            file: file,
            line: line
        )
    }
}

extension TimeInterval {
    /// A cart write is a real round trip to the BFF, so it gets longer than a local UI transition.
    static let bffWrite: TimeInterval = 20
}
