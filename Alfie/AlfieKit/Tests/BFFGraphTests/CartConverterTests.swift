import XCTest
import ApolloTestSupport
@testable import BFFGraph
@testable import Core

final class CartConverterTests: XCTestCase {
    // MARK: - Line mapping

    func test_maps_line_fields_from_the_fragment() throws {
        let cart = makeFragment(lines: [
            makeLine(
                id: "line-1",
                productId: "prod-1",
                variantId: "var-1",
                sku: "SKU-1",
                name: "Silk Shirt",
                quantity: 2,
                imageURL: "https://cdn.alfie.test/shirt.jpg",
                imageAltText: "Silk shirt, front view",
                unitAmount: 19.99,
                lineTotalAmount: 39.98
            ),
        ]).convertToCart()

        XCTAssertEqual(cart.id, "cart-1")
        let line = try XCTUnwrap(cart.lines.first)
        XCTAssertEqual(line.id, "line-1")
        XCTAssertEqual(line.productId, "prod-1")
        XCTAssertEqual(line.variantId, "var-1")
        XCTAssertEqual(line.sku, "SKU-1")
        XCTAssertEqual(line.name, "Silk Shirt")
        XCTAssertEqual(line.imageURL, URL(string: "https://cdn.alfie.test/shirt.jpg"))
        XCTAssertEqual(line.imageAltText, "Silk shirt, front view")
        XCTAssertEqual(line.quantity, 2)
        XCTAssertEqual(line.unitPrice?.amount, 1999)
        XCTAssertEqual(line.lineTotal?.amount, 3998)
    }

    func test_a_null_line_name_maps_to_nil_rather_than_dropping_the_line() throws {
        // `CartItem.name` is nullable on the BFF. A nameless line is still a line the shopper
        // paid for — it must survive conversion so the bag total stays honest.
        let cart = makeFragment(lines: [makeLine(id: "line-1", name: nil)]).convertToCart()

        XCTAssertEqual(cart.lines.count, 1)
        XCTAssertNil(try XCTUnwrap(cart.lines.first).name)
    }

    func test_a_null_line_image_maps_to_nil_url() throws {
        let cart = makeFragment(lines: [makeLine(id: "line-1", imageURL: nil)]).convertToCart()

        let line = try XCTUnwrap(cart.lines.first)
        XCTAssertNil(line.imageURL)
        XCTAssertNil(line.imageAltText)
    }

    func test_an_empty_cart_maps_to_no_lines() {
        let cart = makeFragment(lines: []).convertToCart()

        XCTAssertTrue(cart.lines.isEmpty)
        XCTAssertEqual(cart.totalQuantity, 0)
    }

    func test_a_non_finite_line_total_maps_to_no_total_rather_than_zero() throws {
        // `Decimal(inf)` traps and `Decimal(nan)` overflows, so the shared money conversion falls
        // back to zero. Zero here would print £0.00 — a price the shopper is not being charged,
        // stated as though they were. The bag needs to know the total is unknown to say so.
        let cart = makeFragment(lines: [makeLine(id: "line-1", lineTotalAmount: .nan)]).convertToCart()

        XCTAssertNil(try XCTUnwrap(cart.lines.first).lineTotal)
    }

    func test_a_non_finite_unit_price_maps_to_no_price_rather_than_zero() throws {
        // Same reasoning as the line total: £0.00 beside a real line states a price the shopper is
        // not being charged.
        let cart = makeFragment(lines: [makeLine(id: "line-1", unitAmount: .nan)]).convertToCart()

        XCTAssertNil(try XCTUnwrap(cart.lines.first).unitPrice)
    }

    // MARK: - Totals

    func test_non_finite_totals_map_to_no_total_rather_than_zero() {
        // The grand total is the number a shopper checks before checking out, so a fabricated
        // £0.00 is the worst place of all to state a price they are not being charged (Q36).
        let cart = makeFragment(lines: [], subtotal: .nan, grandTotal: .infinity).convertToCart()

        XCTAssertNil(cart.subtotal)
        XCTAssertNil(cart.grandTotal)
    }

    func test_an_amount_outside_decimals_range_maps_to_no_total_rather_than_zero() throws {
        // `1e300` is *finite*, so a guard that only tests `isFinite` lets it through — but it is
        // outside `Decimal`'s range (the limit sits between 1e120 and 1e140), `Decimal(string:)`
        // returns nil, and the zero fallback prints £0.00. Reachable from legal JSON: Apollo
        // deserialises with `JSONSerialization`, which has no Infinity literal but accepts a large
        // exponent.
        let cart = makeFragment(
            lines: [makeLine(id: "line-1", unitAmount: 1e300, lineTotalAmount: 1e300)],
            subtotal: 1e300,
            grandTotal: 1e300
        ).convertToCart()

        XCTAssertNil(cart.subtotal)
        XCTAssertNil(cart.grandTotal)
        let line = try XCTUnwrap(cart.lines.first)
        XCTAssertNil(line.unitPrice)
        XCTAssertNil(line.lineTotal)
    }

    func test_a_negative_infinity_amount_maps_to_no_total_rather_than_zero() throws {
        // The reachable non-finite case: `-1e400` is legal JSON that `JSONSerialization` parses to
        // `-inf` (it rejects the positive overflow, which is a Foundation asymmetry rather than a
        // rule to rely on). Pinned apart from `.nan` because `Decimal(string: "-inf")` returns 0,
        // not nil — so a guard that only tested the Decimal conversion would print £0.00 here.
        let cart = makeFragment(
            lines: [makeLine(id: "line-1", unitAmount: -.infinity, lineTotalAmount: -.infinity)],
            subtotal: -.infinity,
            grandTotal: -.infinity
        ).convertToCart()

        XCTAssertNil(cart.subtotal)
        XCTAssertNil(cart.grandTotal)
        let line = try XCTUnwrap(cart.lines.first)
        XCTAssertNil(line.unitPrice)
        XCTAssertNil(line.lineTotal)
    }

    func test_maps_subtotal_and_grand_total() {
        let cart = makeFragment(lines: [], subtotal: 19.99, grandTotal: 24.99).convertToCart()

        XCTAssertEqual(cart.subtotal?.amount, 1999)
        XCTAssertEqual(cart.grandTotal?.amount, 2499)
        XCTAssertEqual(cart.grandTotal?.currencyCode, "GBP")
    }

    // MARK: - Money

    func test_money_conversion_is_pinned_for_cart_totals() {
        // The BFF sends a major-unit Double; the bag renders minor units. `0.005` is the half-way
        // case — GBP rounds half away from zero, so it must land on 1p, not 0p.
        let cases: [(amount: Double, expectedMinorUnits: Int)] = [
            (19.99, 1999),
            (0.1, 10),
            (0.005, 1),
        ]

        for (amount, expected) in cases {
            let cart = makeFragment(lines: [], subtotal: amount, grandTotal: amount).convertToCart()
            XCTAssertEqual(
                cart.subtotal?.amount, expected,
                "amount \(amount) should convert to \(expected) minor units, got \(String(describing: cart.subtotal?.amount))"
            )
        }
    }
}

// MARK: - Test factory

private extension CartConverterTests {
    func makeFragment(
        lines: [Mock<CartItem>],
        subtotal: Double = 0,
        grandTotal: Double = 0,
        currencyCode: String = "GBP"
    ) -> BFFGraphAPI.CartFragment {
        let totals = Mock<CartTotals>(
            grandTotal: Mock<Money>(amount: grandTotal, currencyCode: currencyCode),
            subtotal: Mock<Money>(amount: subtotal, currencyCode: currencyCode)
        )

        let cart = Mock<Cart>()
        cart.id = "cart-1"
        cart.lineItems = lines
        cart.totals = totals

        return BFFGraphAPI.CartFragment.from(cart)
    }

    // swiftlint:disable:next function_parameter_count
    func makeLine(
        id: String,
        productId: String? = "prod-1",
        variantId: String? = "var-1",
        sku: String? = "SKU-1",
        name: String? = "Line",
        quantity: Int = 1,
        imageURL: String? = "https://cdn.alfie.test/line.jpg",
        imageAltText: String? = "Line image",
        unitAmount: Double = 5.00,
        lineTotalAmount: Double = 5.00,
        currencyCode: String = "GBP"
    ) -> Mock<CartItem> {
        let line = Mock<CartItem>()
        line.id = id
        line.productId = productId
        line.variantId = variantId
        line.sku = sku
        line.name = name
        line.quantity = quantity
        line.image = imageURL.map { Mock<Image>(altText: imageAltText, url: $0) }
        line.price = Mock<Money>(amount: unitAmount, currencyCode: currencyCode)
        line.lineTotal = Mock<Money>(amount: lineTotalAmount, currencyCode: currencyCode)
        return line
    }
}
