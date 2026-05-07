import XCTest

/// Smoke test demonstrating the centralised accessibility identifier convention
/// for the Product Details (PDP) screen via the `ProductDetailsPage` page object.
///
/// Skipped pending UI-test launch arguments to deep-link into PDP. Remove the
/// `XCTSkip` once that scaffolding exists and update the navigation step.
final class ProductDetailsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddToBagButtonIsAccessible() throws {
        throw XCTSkip("Pending UI-test launch arguments to navigate to Product Details")

        // let app = XCUIApplication()
        // app.launchArguments += ["-uiTestRoute", "productDetails"]
        // app.launch()
        //
        // let page = ProductDetailsPage(app: app)
        // page.assertVisible()
        // page.tapAddToBag()
    }
}
