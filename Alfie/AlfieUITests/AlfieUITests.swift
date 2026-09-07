import AccessibilityIdentifiers
import XCTest

final class AlfieUITests: XCTestCase {
    private var app: XCUIApplication!
    private let timeout: TimeInterval = 5
    /// A cart write is a real round trip to the BFF, so it gets longer than a local UI transition.
    private let writeTimeout: TimeInterval = 20

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

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
    }

    private func waitFor(_ element: XCUIElement, _ message: String) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), message)
    }

    // MARK: - Tests

    /// End-to-end journey: Home → Shop → first category → first product → add to bag →
    /// success Snackbar.
    ///
    /// …then Bag tab → the line is there with totals → tap it → its PDP opens → back → swipe →
    /// Remove → it is gone.
    ///
    /// Needs a reachable BFF: both the add and the removal are real round trips, not local
    /// appends. The bag half was dropped by #116, when the write moved to the server cart while
    /// the Bag screen still read local storage; #117 pointed the screen at the cart and restores
    /// it here.
    ///
    /// Locators outside PDP still use raw identifier strings
    /// (`shop-tab`, `category-item`, `product-image`, `bag-tab`,
    /// `product-name`). Migrating the remainder into the
    /// `AccessibilityIdentifiers` module is tracked as a separate follow-up.
    func testAddToBagFullFlow() throws {
        let pdp = ProductDetailsPage(app: app)
        var expectedProductName = ""

        XCTContext.runActivity(named: "Open the Shop tab") { _ in
            let shopTab = app.otherElements[AccessibilityID.TabBar.shop]
            waitFor(shopTab, "Shop tab should exist")
            shopTab.tap()
        }

        XCTContext.runActivity(named: "Open the first category in the Shop menu") { _ in
            // Shop reached the PDP through a Brands segment until #104 replaced the segmented
            // control with a plain category list read from the BFF menu. Every item that menu
            // returns is a leaf, so one tap opens that collection's listing directly.
            let firstCategory = app.buttons.matching(identifier: "category-item").element(boundBy: 0)
            waitFor(firstCategory, "At least one category should be available")
            firstCategory.tap()
        }

        XCTContext.runActivity(named: "Open the first product in the listing") { _ in
            let firstProduct = app.images.matching(identifier: "product-image").element(boundBy: 0)
            waitFor(firstProduct, "At least one product should be available")
            firstProduct.tap()
        }

        XCTContext.runActivity(named: "PDP is visible, capture product name") { _ in
            pdp.assertVisible(timeout: timeout)
            let name = pdp.productName.label
            XCTAssertFalse(name.isEmpty, "Product name should be non-empty on PDP")
            expectedProductName = name
        }

        XCTContext.runActivity(named: "Add to bag") { _ in
            waitFor(pdp.addToBagButton, "Add to bag button should exist")
            XCTAssertTrue(pdp.addToBagButton.isEnabled, "Add to bag should be enabled for a purchasable variant")
            pdp.tapAddToBag()
        }

        XCTContext.runActivity(named: "The write is confirmed, on the PDP") { _ in
            // The cart round trip has to land, so this waits longer than the standard timeout.
            let snackbar = app.staticTexts[AccessibilityID.Snackbar.text]
            XCTAssertTrue(
                snackbar.waitForExistence(timeout: writeTimeout),
                "A Snackbar should confirm the add — check a BFF is reachable at the dev endpoint"
            )
            XCTAssertEqual(snackbar.label, "Added to bag", "The add should succeed, not fail")
        }

        XCTContext.runActivity(named: "Adding does not navigate away from the PDP") { _ in
            XCTAssertEqual(
                pdp.productName.label,
                expectedProductName,
                "The PDP should still be showing the product that was added"
            )
        }

        let bag = BagPage(app: app)
        var lineCountAfterAdd = 0

        XCTContext.runActivity(named: "The bag shows the line that was added, with totals") { _ in
            bag.open()
            XCTAssertTrue(
                bag.lineItems.element(boundBy: 0).waitForExistence(timeout: writeTimeout),
                "The bag should render the line just added — check a BFF is reachable"
            )
            lineCountAfterAdd = bag.lineItems.count
            XCTAssertGreaterThan(lineCountAfterAdd, 0, "The bag should hold at least the line just added")
            XCTAssertTrue(bag.subtotal.exists, "A bag with lines shows a subtotal")
            XCTAssertTrue(bag.grandTotal.exists, "A bag with lines shows a total")
        }

        XCTContext.runActivity(named: "Tapping a line opens its product, and back returns to the bag") { _ in
            // The row tapped is whichever line is first, which need not be the one just added — the
            // cart id persists across launches. That the PDP opens at all is the claim; which
            // product it lands on is the view model's business and is pinned by its unit tests.
            bag.tapLine(bag.lineItems.element(boundBy: 0))
            pdp.assertVisible(timeout: timeout)

            pdp.tapBack()

            XCTAssertTrue(
                bag.lineItems.element(boundBy: 0).waitForExistence(timeout: timeout),
                "Back from the PDP should return to the bag"
            )
            XCTAssertEqual(
                bag.lineItems.count, lineCountAfterAdd,
                "Coming back from a product must leave the bag exactly as it was"
            )
        }

        XCTContext.runActivity(named: "Swiping a line and tapping Remove drops it on the server") { _ in
            // The cart id persists across launches, so the bag may hold lines from earlier runs.
            // Asserting the count fell by one is stable where asserting it reached zero is not.
            bag.removeLine(bag.lineItems.element(boundBy: 0))

            let expected = lineCountAfterAdd - 1
            let dropped = NSPredicate(format: "count == %d", expected)
            expectation(for: dropped, evaluatedWith: bag.lineItems)
            waitForExpectations(timeout: writeTimeout) { error in
                XCTAssertNil(error, "Removing a line should leave \(expected) — the removal is a server write")
            }
        }
    }

    /// The bag half of #129 on its own: tapping a line opens that line's product, and coming back
    /// leaves the bag as it was.
    ///
    /// `testAddToBagFullFlow` covers the same ground but only reaches it through Add to Bag, which
    /// the PDP disables for anything the BFF reports as out of stock. Whether the catalogue behind
    /// the BFF happens to carry stock is not a fact about this behaviour, so this test seeds the
    /// cart on the server instead and hands the app the id through `-cartId`. That lands in
    /// `UserDefaults`' argument domain, which is where `CartService` reads its stored id from — so
    /// the app needs no test-only branch to accept it.
    func testTappingABagLineOpensItsProduct() throws {
        let cartId = try seedServerCartWithOneLine()

        app.terminate()
        app.launchArguments += ["-cartId", cartId]
        app.launch()

        let bag = BagPage(app: app)
        let pdp = ProductDetailsPage(app: app)
        var lineCount = 0

        XCTContext.runActivity(named: "The bag renders the seeded line") { _ in
            bag.open()
            XCTAssertTrue(
                bag.lineItems.element(boundBy: 0).waitForExistence(timeout: writeTimeout),
                "The seeded cart should render a line — check a BFF is reachable"
            )
            lineCount = bag.lineItems.count
        }

        XCTContext.runActivity(named: "Tapping the line opens its product, and back returns") { _ in
            bag.tapLine(bag.lineItems.element(boundBy: 0))
            pdp.assertVisible(timeout: timeout)

            pdp.tapBack()

            XCTAssertTrue(
                bag.lineItems.element(boundBy: 0).waitForExistence(timeout: timeout),
                "Back from the PDP should return to the bag"
            )
            XCTAssertEqual(
                bag.lineItems.count, lineCount,
                "Coming back from a product must leave the bag exactly as it was"
            )
        }
    }

    // MARK: - Cart seeding

    private enum SeedError: Error {
        case badResponse(String)
        case badOrigin(String)
    }

    /// Creates a cart on the BFF holding the first variant of the first product of the first
    /// collection, and returns its id. Nothing about the catalogue is hard-coded: the collection is
    /// read from the same menu the Shop screen reads, so this follows whichever store the BFF is
    /// pointed at.
    private func seedServerCartWithOneLine() throws -> String {
        let menu = try bffQuery(
            """
            { menu(handle: "main-menu") { items { url } } }
            """
        )
        guard
            let items = (menu["menu"] as? [String: Any])?["items"] as? [[String: Any]],
            let url = items.first?["url"] as? String
        else {
            throw SeedError.badResponse("no menu items: \(menu)")
        }
        let collectionHandle = url.hasPrefix("/") ? String(url.dropFirst()) : url

        let listing = try bffQuery(
            """
            { productList(collectionHandle: "\(collectionHandle)", limit: 1) \
            { products { id variants { id } } } }
            """
        )
        guard
            let products = (listing["productList"] as? [String: Any])?["products"] as? [[String: Any]],
            let product = products.first,
            let productId = product["id"] as? String,
            let variantId = (product["variants"] as? [[String: Any]])?.first?["id"] as? String
        else {
            throw SeedError.badResponse("no products in \(collectionHandle): \(listing)")
        }

        let created = try bffQuery(
            """
            mutation { createCart(input: { lines: [{ productId: "\(productId)", \
            variantId: "\(variantId)", quantity: 1 }] }) { id } }
            """
        )
        guard let cartId = (created["createCart"] as? [String: Any])?["id"] as? String else {
            throw SeedError.badResponse("no cart id: \(created)")
        }
        return cartId
    }

    /// Posts one GraphQL document to the BFF and returns its `data` object. Synchronous because a
    /// seed has to be finished before the app launches, not racing it.
    private func bffQuery(_ document: String) throws -> [String: Any] {
        let origin = ProcessInfo.processInfo.environment["ALFIE_BFF_BASE_URL"] ?? "http://localhost:3000"
        guard let url = URL(string: origin + "/graphql") else {
            throw SeedError.badOrigin(origin)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["query": document])

        var payload: [String: Any]?
        var transportError: Error?
        let replied = expectation(description: "The BFF replies")
        URLSession.shared.dataTask(with: request) { data, _, error in
            transportError = error
            payload = data.flatMap { try? JSONSerialization.jsonObject(with: $0) } as? [String: Any]
            replied.fulfill()
        }
        .resume()
        wait(for: [replied], timeout: writeTimeout)

        if let transportError {
            throw transportError
        }
        guard let data = payload?["data"] as? [String: Any] else {
            throw SeedError.badResponse(String(describing: payload))
        }
        return data
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
