import XCTest

final class AlfieUITests: AlfieUITestCase {
    override func tearDownWithError() throws {
        // Attach screenshot + accessibility hierarchy on every test; both use
        // `.deleteOnSuccess`, so Xcode prunes them on green runs and keeps
        // them only when the test fails. The AX dump is what Xcode never
        // captures on its own and is usually what you need to diagnose
        // "element not found" failures.
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = "Final screen — \(name)"
        screenshot.lifetime = .deleteOnSuccess
        add(screenshot)

        let hierarchy = XCTAttachment(string: app.debugDescription)
        hierarchy.name = "Accessibility hierarchy — \(name)"
        hierarchy.lifetime = .deleteOnSuccess
        add(hierarchy)

        try super.tearDownWithError()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                Self.makeApp().launch()
            }
        }
    }
}
