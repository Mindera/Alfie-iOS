import XCTest
@testable import Model

final class CartTests: XCTestCase {
    func test_total_quantity_sums_line_quantities_rather_than_counting_lines() {
        // Two lines holding 2 and 3 units is a bag of 5, not a bag of 2. The tab badge reads
        // this value, so counting lines would under-report every multi-quantity bag.
        let cart = makeCart(lines: [makeLine(id: "a", quantity: 2), makeLine(id: "b", quantity: 3)])

        XCTAssertEqual(cart.totalQuantity, 5)
    }

    func test_total_quantity_of_an_empty_cart_is_zero() {
        XCTAssertEqual(makeCart(lines: []).totalQuantity, 0)
    }

    // MARK: - Helpers

    private func makeCart(lines: [CartLine]) -> Cart {
        Cart(id: "cart-1", lines: lines, subtotal: money(0), grandTotal: money(0))
    }

    private func makeLine(id: String, quantity: Int) -> CartLine {
        CartLine(
            id: id,
            productId: "product-1",
            variantId: "variant-\(id)",
            sku: "sku-\(id)",
            name: "Line \(id)",
            imageURL: nil,
            imageAltText: nil,
            quantity: quantity,
            unitPrice: money(1000),
            lineTotal: money(1000 * quantity)
        )
    }

    private func money(_ amount: Int) -> Money {
        Money(currencyCode: "GBP", amount: amount, amountFormatted: "£\(amount)")
    }
}
