import AccessibilityIdentifiers
import XCTest

final class AlfieUITests: XCTestCase {
    private var app: XCUIApplication!
    private let timeout: TimeInterval = 5
    /// A cart write is a real round trip to the BFF, so it gets longer than a local UI transition.
    private let writeTimeout: TimeInterval = 20
    /// `MainMenu.graphql` requests three levels of items, so the menu cannot nest deeper than that.
    private let menuDepthLimit = 3

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

        XCTContext.runActivity(named: "Follow the Shop menu down to a product listing") { _ in
            // Shop reached the PDP through a Brands segment until #104 replaced the segmented
            // control with a plain category list read from the BFF menu. A menu item that has
            // children drills into a sub-list instead of opening a listing — see
            // `CategoriesViewModel.didSelectCategory` — and that sub-list is the same
            // `CategoriesView` under the same identifier. So follow the first item down until
            // products appear, rather than assuming the first entry is a leaf and failing on the
            // shape of the store's menu instead of on a defect.
            for _ in 0 ..< menuDepthLimit {
                let firstCategory = app.buttons.matching(identifier: "category-item").element(boundBy: 0)
                waitFor(firstCategory, "At least one category should be available")
                firstCategory.tap()

                let firstProduct = app.images.matching(identifier: "product-image").element(boundBy: 0)
                if firstProduct.waitForExistence(timeout: timeout) {
                    return
                }
            }
            XCTFail("Followed the menu \(menuDepthLimit) levels down without reaching a listing")
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

        XCTContext.runActivity(named: "Swiping the line and tapping Remove drops it on the server") { _ in
            // The row is a full-row `Button` inside a `List` as of #129, so the swipe now competes
            // with the button's own gesture — exactly the interaction that tends to break on an OS
            // update. `testAddToBagFullFlow` covers it too but cannot run wherever the catalogue
            // reports no stock, which left the gesture with no executed test at all.
            //
            // The seeded id is read-only for this launch (see `seedServerCartWithOneLine`), so the
            // removal lands on the server while the app keeps the same cart. Asserting the count
            // fell by one is what stays true either way.
            bag.removeLine(bag.lineItems.element(boundBy: 0))

            let expected = lineCount - 1
            let dropped = NSPredicate(format: "count == %d", expected)
            expectation(for: dropped, evaluatedWith: bag.lineItems)
            waitForExpectations(timeout: writeTimeout) { error in
                XCTAssertNil(error, "Removing a line should leave \(expected) — the removal is a server write")
            }
        }
    }

    // MARK: - Cart seeding

    private enum SeedError: Error {
        case badResponse(String)
        case badOrigin(String)
    }

    /// Creates a cart on the BFF holding the first variant of the first product of the first *leaf*
    /// collection, and returns its id. The collection is read from the same menu the Shop screen
    /// reads, so this follows whichever store the BFF is pointed at; the only fixed string is the
    /// menu handle, which is the schema's own default for `menu(handle:)`.
    ///
    /// The id reaches the app through `-cartId`, which lands in `UserDefaults`' argument domain —
    /// searched *above* the application domain, which is why `CartService` picks it up with no
    /// test-only branch. The same precedence makes it **read-only for that launch**:
    /// `userDefaults.set(_:for:)` writes the application domain and stays shadowed, and
    /// `remove(for:)` cannot clear an argument-domain value at all. Fine for a test that reads, or
    /// that writes through the server, but a test needing the app to *forget* the id — #127's
    /// cart-not-found recovery — cannot be built on this helper.
    private func seedServerCartWithOneLine() throws -> String {
        let menu = try bffQuery(
            """
            query($handle: String!) {
                menu(handle: $handle) { items { url items { url items { url } } } }
            }
            """,
            variables: ["handle": "main-menu"]
        )
        guard
            let items = (menu["menu"] as? [String: Any])?["items"] as? [[String: Any]],
            let url = Self.firstLeafURL(in: items)
        else {
            throw SeedError.badResponse("no leaf menu item: \(menu)")
        }
        let collectionHandle = url.hasPrefix("/") ? String(url.dropFirst()) : url

        let listing = try bffQuery(
            """
            query($collectionHandle: String!) {
                productList(collectionHandle: $collectionHandle, limit: 1) {
                    products { id variants { id } }
                }
            }
            """,
            variables: ["collectionHandle": collectionHandle]
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
            mutation($productId: ID!, $variantId: ID!) {
                createCart(
                    input: { lines: [{ productId: $productId, variantId: $variantId, quantity: 1 }] }
                ) { id }
            }
            """,
            variables: ["productId": productId, "variantId": variantId]
        )
        guard let cartId = (created["createCart"] as? [String: Any])?["id"] as? String else {
            throw SeedError.badResponse("no cart id: \(created)")
        }
        return cartId
    }

    /// The first childless item of the menu, depth first. `MenuItem.items` is populated on a parent
    /// and `MenuItem.url` is nullable, so only a leaf's url is a collection handle a listing can be
    /// opened by — the same branch `CategoriesViewModel.didSelectCategory` takes.
    private static func firstLeafURL(in items: [[String: Any]]) -> String? {
        for item in items {
            let children = item["items"] as? [[String: Any]] ?? []
            if children.isEmpty {
                if let url = item["url"] as? String, !url.isEmpty {
                    return url
                }
            } else if let nested = firstLeafURL(in: children) {
                return nested
            }
        }
        return nil
    }

    /// Posts one GraphQL document to the BFF and returns its `data` object. Synchronous because a
    /// seed has to be finished before the app launches, not racing it. Arguments travel as
    /// `variables` rather than interpolated into the document, so a value carrying a quote cannot
    /// reshape the query into something that fails opaquely.
    private func bffQuery(_ document: String, variables: [String: Any] = [:]) throws -> [String: Any] {
        let origin = ProcessInfo.processInfo.environment["ALFIE_BFF_BASE_URL"] ?? "http://localhost:3000"
        guard let url = URL(string: origin + "/graphql") else {
            throw SeedError.badOrigin(origin)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(
            withJSONObject: ["query": document, "variables": variables]
        )

        var payload: [String: Any]?
        var status = 0
        var transportError: Error?
        let replied = expectation(description: "The BFF replies")
        URLSession.shared.dataTask(with: request) { data, response, error in
            transportError = error
            status = (response as? HTTPURLResponse)?.statusCode ?? 0
            payload = data.flatMap { try? JSONSerialization.jsonObject(with: $0) } as? [String: Any]
            replied.fulfill()
        }
        .resume()
        wait(for: [replied], timeout: writeTimeout)

        if let transportError {
            throw transportError
        }
        // A GraphQL failure arrives as HTTP 200 carrying `errors` beside a null field, so without
        // this the caller's own guard trips instead and reports the shape of the reply — "no leaf
        // menu item: [menu: <null>]" — while the server's actual message is discarded.
        if let errors = payload?["errors"] {
            throw SeedError.badResponse("HTTP \(status), GraphQL errors: \(errors)")
        }
        guard let data = payload?["data"] as? [String: Any] else {
            throw SeedError.badResponse("HTTP \(status): \(String(describing: payload))")
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
