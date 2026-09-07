import Model
import XCTest

/// Drives the whole cart lifecycle against a running BFF: create, re-add, add, remove, read.
///
/// The load-bearing assertion lives in `test_cart_round_trip_creates_merges_adds_removes_and_reads_back`:
/// re-adding a variant already in the cart merges into one line with the quantity summed. Merging is
/// documented platform behaviour that no BFF test covers, and the app's entire quantity story rests
/// on it — if it were false, quantity would have to be tracked client-side.
final class CartIntegrationTests: IntegrationTestCase {
    func test_cart_round_trip_creates_merges_adds_removes_and_reads_back() async throws {
        let (first, second) = try await twoAddableVariants()

        let created = try await sut.createCart(lines: [first])
        XCTAssertFalse(created.id.isEmpty, "createCart must return a usable cart id")
        XCTAssertEqual(created.lines.count, 1, "The create input carried one line")
        XCTAssertEqual(created.totalQuantity, 1)
        try assertTotalsAreConsistent(created)

        // Re-adding the same variant must merge, not append.
        let merged = try await sut.addToCart(cartId: created.id, lines: [first])
        XCTAssertEqual(merged.lines.count, 1, "Re-adding the same variant must merge into one line")
        XCTAssertEqual(merged.lines.first?.quantity, 2, "The merged line must carry the summed quantity")
        XCTAssertEqual(merged.totalQuantity, 2)

        // A different variant is a new line.
        let twoLines = try await sut.addToCart(cartId: created.id, lines: [second])
        XCTAssertEqual(twoLines.lines.count, 2, "A different variant must open its own line")
        XCTAssertEqual(twoLines.totalQuantity, 3)
        try assertTotalsAreConsistent(twoLines)

        let secondLine = try XCTUnwrap(
            twoLines.lines.first { $0.variantId == second.variantId },
            "The second variant should be present as its own line"
        )
        let afterRemoval = try await sut.removeFromCart(cartId: created.id, lineId: secondLine.id)
        XCTAssertEqual(afterRemoval.lines.count, 1)
        XCTAssertEqual(afterRemoval.totalQuantity, 2)
        try assertTotalsAreConsistent(afterRemoval)

        let readBack = try await sut.getCart(cartId: created.id)
        XCTAssertEqual(readBack.id, created.id)
        XCTAssertEqual(readBack.lines.count, 1, "The removal must survive a fresh read")
        XCTAssertEqual(readBack.lines.first?.variantId, first.variantId)
        XCTAssertEqual(readBack.totalQuantity, 2)
        try assertTotalsAreConsistent(readBack)
    }

    func test_every_line_carries_both_a_product_id_and_a_variant_id() async throws {
        // BigCommerce throws BadRequestException on a line without `productId`; Shopify ignores it.
        // Sending both is the only input shape that works on either platform.
        let (first, _) = try await twoAddableVariants()

        let cart = try await sut.createCart(lines: [first])

        let line = try XCTUnwrap(cart.lines.first)
        XCTAssertEqual(line.productId, first.productId)
        XCTAssertEqual(line.variantId, first.variantId)
    }

    /// Pins the wire shape of a cart-not-found so the recovery work (ticket 5) starts from a
    /// verified premise. Deliberately asserted on the raw response — mapping it to a typed error is
    /// not this ticket's job.
    ///
    /// The id must be *well-formed* but unknown, which is what an expired cart id looks like. A
    /// syntactically invalid id is a different failure: the platform rejects it before the lookup
    /// and the BFF reports `status` 500, so it would not exercise the recovery path at all.
    func test_an_unknown_cart_id_comes_back_with_a_404_status_extension() async throws {
        let body = try await rawGraphQL(
            query: "query($cartId: String!) { cart(cartId: $cartId) { id } }",
            variables: ["cartId": try await unknownButWellFormedCartId()]
        )

        let errors = try XCTUnwrap(body["errors"] as? [[String: Any]], "Expected a GraphQL error")
        let extensions = try XCTUnwrap(errors.first?["extensions"] as? [String: Any])
        XCTAssertEqual(
            extensions["status"] as? Int, 404,
            "Cart-not-found is identified by extensions.status; got \(extensions)"
        )
    }

    /// The premise above, carried all the way through the typed client — which is what the recovery
    /// in `CartService` actually consumes. The raw assertion pins only the response *body*, and two
    /// things sit between that body and a `.cart(.cartNotFound)`: the BFF has to answer HTTP 200
    /// (`ResponseCodeInterceptor` throws on any non-2xx before the GraphQL errors are ever read),
    /// and `getCart` has to apply the mapping. Neither is visible from the raw shape, and a unit
    /// test cannot see them either — it stubs the error it wants at the client boundary.
    func test_getCart_with_an_unknown_cart_id_arrives_as_a_cart_not_found_error() async throws {
        let unknownId = try await unknownButWellFormedCartId()

        do {
            _ = try await sut.getCart(cartId: unknownId)
            XCTFail("Expected a cart-not-found for an unknown cart id")
        } catch {
            XCTAssertEqual(
                (error as? BFFRequestError)?.type, .cart(.cartNotFound),
                "The bag renders empty off this exact type; got \(error)"
            )
        }
    }

    /// The same for the add path, which recovers differently: it starts a fresh cart carrying the
    /// line rather than emptying the bag, so it needs the same type to arrive.
    func test_addToCart_with_an_unknown_cart_id_arrives_as_a_cart_not_found_error() async throws {
        let (first, _) = try await twoAddableVariants()
        let unknownId = try await unknownButWellFormedCartId()

        do {
            _ = try await sut.addToCart(cartId: unknownId, lines: [first])
            XCTFail("Expected a cart-not-found for an unknown cart id")
        } catch {
            XCTAssertEqual(
                (error as? BFFRequestError)?.type, .cart(.cartNotFound),
                "The add-time recovery turns on this exact type; got \(error)"
            )
        }
    }

    /// A real cart id with its token perturbed — same shape, no such cart.
    private func unknownButWellFormedCartId() async throws -> String {
        let (first, _) = try await twoAddableVariants()
        let realId = try await sut.createCart(lines: [first]).id

        // The id carries a `?key=` suffix; the token before it is what identifies the cart.
        let token = realId.prefix { $0 != "?" }
        let query = realId.dropFirst(token.count)
        return token.dropLast(4) + "ZZZZ" + query
    }

    // MARK: - Totals

    private func assertTotalsAreConsistent(_ cart: Cart, file: StaticString = #filePath, line: UInt = #line) throws {
        // A missing line total is the non-finite case, which a real cart never sends. Asserting it
        // separately stops a `nil` being summed as zero and quietly passing the subtotal check.
        XCTAssertFalse(
            cart.lines.contains { $0.lineTotal == nil },
            "Every line of a real cart has a finite total",
            file: file, line: line
        )
        // Totals are optional for the same non-finite reason, and a real cart never sends one.
        // Unwrapping rather than defaulting stops a `nil` passing the comparisons below as zero.
        let subtotal = try XCTUnwrap(cart.subtotal, "A real cart has a finite subtotal", file: file, line: line)
        let grandTotal = try XCTUnwrap(cart.grandTotal, "A real cart has a finite grand total", file: file, line: line)
        let summedLines = cart.lines.reduce(0) { $0 + ($1.lineTotal?.amount ?? 0) }
        XCTAssertEqual(
            subtotal.amount, summedLines,
            "Subtotal must equal the sum of the line totals",
            file: file, line: line
        )
        XCTAssertGreaterThanOrEqual(
            grandTotal.amount, subtotal.amount,
            "Grand total may add tax or shipping but never subtracts from the subtotal",
            file: file, line: line
        )
    }

    // MARK: - Seed discovery

    /// Two distinct variants from the seed store, with the platform ids every cart write needs.
    /// Discovered over the wire rather than hardcoded so a seed-data change doesn't break the test —
    /// and read raw because the domain `Product.Variant` does not yet carry a platform id.
    private func twoAddableVariants() async throws -> (CartLineInput, CartLineInput) {
        let body = try await rawGraphQL(
            query: """
            query($handle: String!) {
                productList(collectionHandle: $handle, limit: 20) {
                    products { variants { id productId } }
                }
            }
            """,
            variables: ["handle": IntegrationSeed.collectionHandle]
        )

        let data = try XCTUnwrap(body["data"] as? [String: Any])
        let products = try XCTUnwrap((data["productList"] as? [String: Any])?["products"] as? [[String: Any]])

        let variants: [CartLineInput] = products
            .compactMap { $0["variants"] as? [[String: Any]] }
            .flatMap { $0 }
            .compactMap { variant in
                guard
                    let variantId = variant["id"] as? String,
                    let productId = variant["productId"] as? String
                else {
                    return nil
                }
                return CartLineInput(productId: productId, variantId: variantId, quantity: 1)
            }

        guard variants.count >= 2 else {
            throw XCTSkip("Seed store exposed fewer than two addable variants in \(IntegrationSeed.collectionHandle)")
        }
        return (variants[0], variants[1])
    }

    /// Posts a query straight at the endpoint and returns the decoded JSON body. Used for seed
    /// discovery and for the raw error-shape assertion, both of which sit below the typed client.
    private func rawGraphQL(query: String, variables: [String: String]) async throws -> [String: Any] {
        var request = URLRequest(url: graphQLEndpoint, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(
            withJSONObject: ["query": query, "variables": variables]
        )

        let (data, _) = try await URLSession.shared.data(for: request)
        return try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
}
