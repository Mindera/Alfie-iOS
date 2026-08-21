import XCTest
@testable import Model

/// The map's standing correctness constraint: `Money.amount` is minor units, the filter speaks
/// major units. A GBP-only fixture passes even when the conversion is wrong, so every case here
/// is mirrored on JPY, whose exponent is 0.
final class PriceFilterBoundsTests: XCTestCase {
    // MARK: - Minor → major conversion

    func test_gbp_minor_units_become_major_units() {
        let bounds = PriceFilterBounds(priceRange: range(low: 1_023, high: 48_000, code: "GBP"))
        XCTAssertEqual(bounds?.minimum, 10, "£10.23 (1023 minor) must become 10, not 1023")
        XCTAssertEqual(bounds?.maximum, 480, "£480.00 (48000 minor) must become 480, not 48000")
    }

    func test_jpy_has_no_exponent_so_minor_and_major_units_coincide() {
        // The case a GBP-only fixture cannot catch: here an unconverted value would look right.
        let bounds = PriceFilterBounds(priceRange: range(low: 800, high: 48_000, code: "JPY"))
        XCTAssertEqual(bounds?.minimum, 800)
        XCTAssertEqual(bounds?.maximum, 48_000)
    }

    func test_kwd_has_three_minor_digits() {
        let bounds = PriceFilterBounds(priceRange: range(low: 19_999, high: 25_000, code: "KWD"))
        XCTAssertEqual(bounds?.minimum, 19, "19.999 KWD floors to 19")
        XCTAssertEqual(bounds?.maximum, 25)
    }

    func test_the_conversion_is_not_a_fixed_divide_by_one_hundred() {
        // Pins the bug directly: same minor amount, different exponents, different major values.
        let gbp = PriceFilterBounds(priceRange: range(low: 1_000, high: 200_000, code: "GBP"))
        let jpy = PriceFilterBounds(priceRange: range(low: 1_000, high: 200_000, code: "JPY"))
        XCTAssertEqual(gbp?.minimum, 10)
        XCTAssertEqual(jpy?.minimum, 1_000)
    }

    // MARK: - Rounding direction

    func test_the_minimum_rounds_down_and_the_maximum_rounds_up() {
        // £10.23 – £47.51 must widen to 10 – 48, never narrow to 11 – 47, or the cheapest and
        // dearest products in the category fall outside their own category's bounds.
        let bounds = PriceFilterBounds(priceRange: range(low: 1_023, high: 4_751, code: "GBP"))
        XCTAssertEqual(bounds?.minimum, 10)
        XCTAssertEqual(bounds?.maximum, 48)
    }

    func test_exact_whole_units_are_left_alone() {
        let bounds = PriceFilterBounds(priceRange: range(low: 1_000, high: 4_800, code: "GBP"))
        XCTAssertEqual(bounds?.minimum, 10)
        XCTAssertEqual(bounds?.maximum, 48)
    }

    func test_a_boundary_priced_product_stays_inside_the_bounds() {
        let low = 1_023, high = 4_751
        let bounds = try? XCTUnwrap(PriceFilterBounds(priceRange: range(low: low, high: high, code: "GBP")))
        XCTAssertLessThanOrEqual(bounds?.minimum ?? .infinity, Double(low) / 100)
        XCTAssertGreaterThanOrEqual(bounds?.maximum ?? -.infinity, Double(high) / 100)
    }

    // MARK: - Nothing to filter on

    func test_an_absent_upper_bound_yields_no_bounds() {
        let openEnded = PriceRange(low: money(1_000, "GBP"), high: nil)
        XCTAssertNil(PriceFilterBounds(priceRange: openEnded))
    }

    func test_a_range_collapsing_to_one_whole_unit_yields_no_bounds() {
        // Every product priced £10.20–£10.60 rounds to 10–11 — still filterable.
        XCTAssertNotNil(PriceFilterBounds(priceRange: range(low: 1_020, high: 1_060, code: "GBP")))
        // Every product priced exactly £10 collapses to 10–10; there is nothing to narrow.
        XCTAssertNil(PriceFilterBounds(priceRange: range(low: 1_000, high: 1_000, code: "GBP")))
    }

    func test_a_free_category_yields_no_bounds() {
        XCTAssertNil(PriceFilterBounds(priceRange: range(low: 0, high: 0, code: "GBP")))
    }

    // MARK: - Range

    func test_range_spans_minimum_to_maximum() {
        let bounds = PriceFilterBounds(currencyCode: "GBP", minimum: 8, maximum: 480)
        XCTAssertEqual(bounds.range, 8...480)
    }

    func test_currency_code_is_carried_through_for_the_field_affix() {
        let bounds = PriceFilterBounds(priceRange: range(low: 800, high: 48_000, code: "JPY"))
        XCTAssertEqual(bounds?.currencyCode, "JPY")
    }

    // MARK: - Helpers

    private func money(_ amount: Int, _ code: String) -> Money {
        Money(currencyCode: code, amount: amount, amountFormatted: "")
    }

    private func range(low: Int, high: Int, code: String) -> PriceRange {
        PriceRange(low: money(low, code), high: money(high, code))
    }
}
