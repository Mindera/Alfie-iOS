import Mocks
import Model
import XCTest
@testable import AppFeature

final class BagBadgeTests: XCTestCase {
    func test_noCart_showsNoBadge() {
        XCTAssertNil(BagBadge.value(for: nil))
    }

    func test_emptyCart_showsNoBadge() {
        XCTAssertNil(BagBadge.value(for: .fixture(lines: [])))
    }

    func test_singleLine_showsItsQuantity() {
        XCTAssertEqual(BagBadge.value(for: .fixture(lines: [.fixture(quantity: 3)])), 3)
    }

    // The badge counts items, not rows: two lines of 3 and 4 are 7, not 2. `Cart.totalQuantity`
    // already sums, so this guards the badge against being rewired to `lines.count` later.
    func test_multipleLines_sumsQuantitiesRatherThanCountingLines() {
        let cart = Cart.fixture(lines: [
            .fixture(id: "line-1", quantity: 3),
            .fixture(id: "line-2", quantity: 4),
        ])
        XCTAssertEqual(BagBadge.value(for: cart), 7)
    }
}
