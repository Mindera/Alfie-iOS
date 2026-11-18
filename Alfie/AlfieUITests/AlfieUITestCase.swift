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

    func open(_ deepLink: UITestDeepLink, file: StaticString = #filePath, line: UInt = #line) {
        guard #available(iOS 16.4, *) else {
            return XCTFail("Opening a deep link needs iOS 16.4 or newer", file: file, line: line)
        }
        guard let url = deepLink.url else {
            return XCTFail("\(deepLink) does not make a deep link", file: file, line: line)
        }
        app.open(url)
    }

    func waitFor(
        _ element: XCUIElement,
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), message, file: file, line: line)
    }

    func waitFor(
        _ element: XCUIElement,
        labelToChangeFrom label: String,
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let labelChanged = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label != %@", label),
            object: element
        )
        let result = XCTWaiter().wait(for: [labelChanged], timeout: timeout)
        XCTAssertEqual(result, .completed, message, file: file, line: line)
    }
}
