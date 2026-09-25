import Model
import XCTest

/// `sizeDisplay` replaced three predicates that used to live in the view, one of which hid the
/// whole size section once nothing in it was buyable. Stock must not reach this decision.
final class VariantSelectionStateTests: XCTestCase {
    func test_a_product_with_no_sizes_is_one_size() {
        let state = VariantSelectionState(sizes: [])

        XCTAssertEqual(state.sizeDisplay, .oneSize)
    }

    func test_a_lone_size_is_named_rather_than_offered_as_a_choice() {
        let state = VariantSelectionState(sizes: [.init(id: "1", name: "UK 6", state: .available)])

        XCTAssertEqual(state.sizeDisplay, .single(name: "UK 6"))
    }

    func test_a_lone_size_is_still_named_when_it_is_out_of_stock() {
        let state = VariantSelectionState(sizes: [.init(id: "1", name: "UK 6", state: .outOfStock)])

        XCTAssertEqual(state.sizeDisplay, .single(name: "UK 6"))
    }

    func test_several_sizes_offer_the_selector() {
        let state = VariantSelectionState(sizes: [
            .init(id: "1", name: "S", state: .available),
            .init(id: "2", name: "M", state: .available),
        ])

        XCTAssertEqual(state.sizeDisplay, .selector)
    }

    /// The regression this type exists to close: every size sold out for the chosen colour still
    /// draws the grid, so the shopper can see which sizes are gone instead of an unexplained dead
    /// call-to-action.
    func test_every_size_out_of_stock_still_offers_the_selector() {
        let state = VariantSelectionState(sizes: [
            .init(id: "1", name: "S", state: .outOfStock),
            .init(id: "2", name: "M", state: .outOfStock),
        ])

        XCTAssertEqual(state.sizeDisplay, .selector)
    }
}
