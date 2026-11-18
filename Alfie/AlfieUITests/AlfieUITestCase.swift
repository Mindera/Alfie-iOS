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

    func openProduct(handle: String, file: StaticString = #filePath, line: UInt = #line) {
        guard #available(iOS 16.4, *) else {
            return XCTFail("Opening a deep link needs iOS 16.4 or newer", file: file, line: line)
        }
        guard let url = URL(string: "alfie://alfie.target/product/\(handle)") else {
            return XCTFail("\(handle) does not make a product deep link", file: file, line: line)
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
}
