@testable import Core
import Mocks
import Model
import XCTest

final class LocalCartServiceTests: XCTestCase {
    private var userDefaults: MockUserDefaults!
    private var sut: LocalCartService!

    override func setUp() {
        super.setUp()
        userDefaults = MockUserDefaults()
        userDefaults.onSetCalled = { [unowned self] value, key in userDefaults.forcedValueForKey[key] = value }
        userDefaults.onRemoveCalled = { [unowned self] key in userDefaults.forcedValueForKey[key] = nil }
        sut = LocalCartService(userDefaults: userDefaults, storageKey: "cart")
    }

    override func tearDown() {
        sut = nil
        userDefaults = nil
        super.tearDown()
    }

    func test_add_with_empty_cart_publishes_line_with_totals() async throws {
        try await sut.add(line: line(variantId: "v-1", quantity: 2, price: 1_250))

        XCTAssertEqual(sut.cart?.lines.map(\.id), ["v-1"])
        XCTAssertEqual(sut.cart?.lines.first?.lineTotal?.amount, 2_500)
        XCTAssertEqual(sut.cart?.subtotal?.amount, 2_500)
        XCTAssertEqual(sut.cart?.grandTotal?.amount, 2_500)
    }

    func test_add_with_same_variant_in_cart_increments_quantity() async throws {
        try await sut.add(line: line(variantId: "v-1", quantity: 1, price: 1_000))

        try await sut.add(line: line(variantId: "v-1", quantity: 1, price: 1_000))

        XCTAssertEqual(sut.cart?.lines.map(\.quantity), [2])
    }

    func test_setQuantity_with_existing_line_replaces_quantity() async throws {
        try await sut.add(line: line(variantId: "v-1", quantity: 1, price: 1_000))

        try await sut.setQuantity(lineId: "v-1", to: 5)

        XCTAssertEqual(sut.cart?.lines.map(\.quantity), [5])
        XCTAssertEqual(sut.cart?.subtotal?.amount, 5_000)
    }

    func test_setQuantity_with_zero_removes_line() async throws {
        try await sut.add(line: line(variantId: "v-1", quantity: 1, price: 1_000))
        try await sut.add(line: line(variantId: "v-2", quantity: 1, price: 2_000))

        try await sut.setQuantity(lineId: "v-1", to: 0)

        XCTAssertEqual(sut.cart?.lines.map(\.id), ["v-2"])
    }

    func test_remove_with_last_line_publishes_nil() async throws {
        try await sut.add(line: line(variantId: "v-1", quantity: 1, price: 1_000))

        try await sut.remove(lineId: "v-1")

        XCTAssertNil(sut.cart)
    }

    func test_remove_with_unknown_line_throws() async {
        do {
            try await sut.remove(lineId: "missing")
            XCTFail("Expected an error")
        } catch {}
    }

    func test_fetch_with_lines_saved_by_previous_session_publishes_them() async throws {
        try await sut.add(line: line(variantId: "v-1", quantity: 3, price: 1_000))
        let relaunched = LocalCartService(userDefaults: userDefaults, storageKey: "cart")

        try await relaunched.fetch()

        XCTAssertEqual(relaunched.cart?.lines.map(\.quantity), [3])
    }

    func test_discardCart_clears_saved_lines() async throws {
        try await sut.add(line: line(variantId: "v-1", quantity: 1, price: 1_000))

        await sut.discardCart()
        try await sut.fetch()

        XCTAssertNil(sut.cart)
    }

    func test_total_with_unknown_price_is_nil() {
        let total = LocalCartService.total(of: [Money(currencyCode: "GBP", amount: 100, amountFormatted: "£1.00"), nil])

        XCTAssertNil(total)
    }

    private func line(variantId: String, quantity: Int, price: Int) -> CartLineInput {
        CartLineInput(
            productId: "p-1",
            variantId: variantId,
            quantity: quantity,
            slug: "slug",
            name: "Name",
            unitPrice: Money(currencyCode: "GBP", amount: price, amountFormatted: "")
        )
    }
}
