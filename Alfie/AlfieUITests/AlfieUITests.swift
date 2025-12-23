import XCTest

final class AlfieUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddToCartFullFlow() throws {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.images["storefront"]/*[[".otherElements[\"shop-tab\"].images",".otherElements.images[\"storefront\"]",".images[\"storefront\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.scrollViews.buttons["Brands"].firstMatch/*[[".buttons",".matching(identifier: \"Brands\")",".element(boundBy: 1)",".containing(.staticText, identifier: \"Brands\").firstMatch",".matching(identifier: \"category-item\").containing(.staticText, identifier: \"Brands\").firstMatch",".scrollViews.buttons[\"Brands\"].firstMatch"],[[[-1,5],[-1,0,1]],[[-1,3],[-1,4],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["04AugPhilos"]/*[[".otherElements.buttons[\"04AugPhilos\"]",".buttons[\"04AugPhilos\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app.images.matching(identifier: "product-image").element(boundBy: 0).tap()

        // Wait for PDP to load and capture product name from the title header
        let addToBagButton = app.buttons["Add to bag"]
        XCTAssertTrue(addToBagButton.waitForExistence(timeout: 5), "Add to bag button should exist")

        // The product name is shown in the title header - get the first static text in the scroll view content
        // which contains the product name (displayed in titleHeader view)
        let productNameOnPDP = app.scrollViews.firstMatch.staticTexts.firstMatch
        XCTAssertTrue(productNameOnPDP.waitForExistence(timeout: 5), "Product name should be visible on PDP")
        let expectedProductName = productNameOnPDP.label

        // Tap "Add to bag" button
        addToBagButton.tap()

        // Navigate back from PDP - tap the first button in navigation bar
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button should exist")
        backButton.tap()

        // Navigate to bag tab
        let bagTab = app.otherElements["bag-tab"]
        XCTAssertTrue(bagTab.waitForExistence(timeout: 5), "Bag tab should exist")
        bagTab.tap()

        // Verify the product in the bag matches the one we added
        let productNameInBag = app.staticTexts.matching(identifier: "product-name").firstMatch
        XCTAssertTrue(productNameInBag.waitForExistence(timeout: 5), "Product name should be visible in bag")
        XCTAssertEqual(productNameInBag.label, expectedProductName, "Product in bag should match the product that was added")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
