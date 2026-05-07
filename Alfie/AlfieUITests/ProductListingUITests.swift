import XCTest

/// Smoke test demonstrating the centralised accessibility identifier convention
/// via the `ProductListingPage` page object.
///
/// This test is currently skipped: it requires a known navigation path to the
/// Product Listing screen (e.g. a UI-test launch argument that deep-links there),
/// which is out of scope for the convention rollout. Remove the `XCTSkip` once
/// that scaffolding exists and update `navigateToProductListing` to drive it.
final class ProductListingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testFilterButtonIsAccessible() throws {
        throw XCTSkip("Pending UI-test launch arguments to navigate to Product Listing")

        // let app = XCUIApplication()
        // app.launchArguments += ["-uiTestRoute", "productListing"]
        // app.launch()
        //
        // let page = ProductListingPage(app: app)
        // page.assertVisible()
        // page.tapFilter()
    }
}
