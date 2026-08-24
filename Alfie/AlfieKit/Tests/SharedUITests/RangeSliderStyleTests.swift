import SwiftUI
import XCTest
@testable import SharedUI

final class RangeSliderStyleTests: XCTestCase {
    private let sut = RangeSliderStyle(bounds: 0...100, step: 1)
    private let coarse = RangeSliderStyle(bounds: 0...100, step: 10)

    // MARK: - Effective values (nil = unbounded)

    func test_nil_bounds_rest_the_thumbs_on_the_track_ends() {
        XCTAssertEqual(sut.effectiveValue(nil, for: .lower), 0)
        XCTAssertEqual(sut.effectiveValue(nil, for: .upper), 100)
    }

    func test_a_set_value_is_used_as_is() {
        XCTAssertEqual(sut.effectiveValue(25, for: .lower), 25)
        XCTAssertEqual(sut.effectiveValue(75, for: .upper), 75)
    }

    // MARK: - Geometry

    func test_fraction_maps_the_bounds_onto_zero_to_one() {
        XCTAssertEqual(sut.fraction(of: 0), 0)
        XCTAssertEqual(sut.fraction(of: 50), 0.5)
        XCTAssertEqual(sut.fraction(of: 100), 1)
    }

    func test_fraction_pins_values_outside_the_bounds_to_the_track_ends() {
        // A user may legitimately type beyond the category range; the value stands, the thumb pins.
        XCTAssertEqual(sut.fraction(of: -20), 0)
        XCTAssertEqual(sut.fraction(of: 900), 1)
    }

    func test_fraction_of_a_degenerate_range_does_not_divide_by_zero() {
        let degenerate = RangeSliderStyle(bounds: 50...50, step: 1)
        XCTAssertEqual(degenerate.fraction(of: 50), 0)
    }

    func test_value_at_fraction_is_the_inverse_of_fraction() {
        XCTAssertEqual(sut.value(atFraction: 0.25), 25)
        XCTAssertEqual(sut.fraction(of: sut.value(atFraction: 0.6)), 0.6, accuracy: 0.0001)
    }

    // MARK: - Stepping (min floors, max ceils)

    func test_lower_thumb_floors_to_the_step_grid() {
        XCTAssertEqual(coarse.stepped(37, for: .lower), 30)
        XCTAssertEqual(coarse.stepped(39.9, for: .lower), 30)
    }

    func test_upper_thumb_ceils_to_the_step_grid() {
        XCTAssertEqual(coarse.stepped(31, for: .upper), 40)
        XCTAssertEqual(coarse.stepped(30.1, for: .upper), 40)
    }

    func test_stepping_never_narrows_the_range_past_a_product_on_the_boundary() {
        // The whole point of floor/ceil: a product priced 37 must survive a 30–40 stepped range.
        let lower = coarse.stepped(37, for: .lower)
        let upper = coarse.stepped(37, for: .upper)
        XCTAssertLessThanOrEqual(lower, 37)
        XCTAssertGreaterThanOrEqual(upper, 37)
    }

    func test_stepping_stays_inside_the_bounds() {
        XCTAssertEqual(coarse.stepped(999, for: .upper), 100)
        XCTAssertEqual(coarse.stepped(-999, for: .lower), 0)
    }

    func test_a_zero_step_disables_snapping_but_still_clamps() {
        let unstepped = RangeSliderStyle(bounds: 0...100, step: 0)
        XCTAssertEqual(unstepped.stepped(37.4, for: .lower), 37.4)
        XCTAssertEqual(unstepped.stepped(140, for: .upper), 100)
    }

    // MARK: - Dragging clamps, never crosses

    func test_dragging_the_lower_thumb_past_the_upper_clamps_at_it() {
        let result = sut.draggedValue(for: .lower, toFraction: 0.9, lower: 20, upper: 60)
        XCTAssertEqual(result, 60)
    }

    func test_dragging_the_upper_thumb_past_the_lower_clamps_at_it() {
        let result = sut.draggedValue(for: .upper, toFraction: 0.1, lower: 40, upper: 80)
        XCTAssertEqual(result, 40)
    }

    func test_dragging_against_a_nil_sibling_clamps_at_the_bound() {
        // No upper limit set — the lower thumb may travel to the top of the track.
        XCTAssertEqual(sut.draggedValue(for: .lower, toFraction: 1, lower: 20, upper: nil), 100)
        XCTAssertEqual(sut.draggedValue(for: .upper, toFraction: 0, lower: nil, upper: 80), 0)
    }

    // MARK: - VoiceOver adjustment

    func test_adjusting_the_lower_thumb_up_stops_at_the_upper_value() {
        XCTAssertEqual(sut.adjustedValue(for: .lower, by: 10, lower: 58, upper: 60), 60)
    }

    func test_adjusting_the_upper_thumb_down_stops_at_the_lower_value() {
        XCTAssertEqual(sut.adjustedValue(for: .upper, by: -10, lower: 40, upper: 42), 40)
    }

    func test_adjusting_stays_inside_the_bounds() {
        XCTAssertEqual(sut.adjustedValue(for: .lower, by: -10, lower: 0, upper: 50), 0)
        XCTAssertEqual(sut.adjustedValue(for: .upper, by: 10, lower: 50, upper: 100), 100)
    }

    // MARK: - Collapsed-range tie-break

    func test_a_touch_left_of_a_collapsed_pair_takes_the_lower_thumb() {
        let thumb = sut.nearestThumb(toFraction: 0.3, lowerFraction: 0.5, upperFraction: 0.5)
        XCTAssertEqual(thumb, .lower)
    }

    func test_a_touch_right_of_a_collapsed_pair_takes_the_upper_thumb() {
        let thumb = sut.nearestThumb(toFraction: 0.7, lowerFraction: 0.5, upperFraction: 0.5)
        XCTAssertEqual(thumb, .upper)
    }

    func test_a_touch_exactly_on_a_collapsed_pair_takes_the_upper_thumb() {
        // Deliberate: with the lower thumb unreachable from the right, the pair could never reopen.
        let thumb = sut.nearestThumb(toFraction: 0.5, lowerFraction: 0.5, upperFraction: 0.5)
        XCTAssertEqual(thumb, .upper)
    }

    func test_the_nearer_thumb_wins_when_the_pair_is_open() {
        XCTAssertEqual(sut.nearestThumb(toFraction: 0.25, lowerFraction: 0.2, upperFraction: 0.8), .lower)
        XCTAssertEqual(sut.nearestThumb(toFraction: 0.75, lowerFraction: 0.2, upperFraction: 0.8), .upper)
    }

    // MARK: - Field round-trip

    func test_a_nil_value_renders_an_empty_field_never_zero() {
        XCTAssertEqual(sut.fieldText(for: nil), "")
    }

    func test_a_value_renders_as_a_whole_number() {
        XCTAssertEqual(sut.fieldText(for: 40), "40")
        XCTAssertEqual(sut.fieldText(for: 39.6), "40")
    }

    func test_clearing_a_field_clears_the_bound() {
        XCTAssertNil(sut.fieldValue(from: "", for: .lower))
        XCTAssertNil(sut.fieldValue(from: "abc", for: .upper))
    }

    func test_typing_snaps_outwards_like_the_thumbs_do() {
        XCTAssertEqual(coarse.fieldValue(from: "37", for: .lower), 30)
        XCTAssertEqual(coarse.fieldValue(from: "31", for: .upper), 40)
    }

    func test_typing_is_not_clamped_against_the_other_bound() {
        // min > max must surface as an inline error (ALFMOB-481), so it has to be representable.
        XCTAssertEqual(sut.fieldValue(from: "90", for: .lower), 90)
    }

    func test_typing_beyond_the_category_bounds_is_kept() {
        // The bounds describe the category, not a cap on what may be filtered.
        XCTAssertEqual(sut.fieldValue(from: "900", for: .upper), 900)
    }

    // MARK: - Oversized input (regression: Int(Double) trap)

    func test_a_value_too_large_for_Int_does_not_crash_the_field() {
        // 19 digits exceeds Int.max as a Double, which the trapping Int() initialiser aborts on.
        // Reachable by holding a key on the .numberPad field.
        let huge = sut.fieldValue(from: String(repeating: "9", count: 19), for: .lower)
        XCTAssertNotNil(huge)
        XCTAssertFalse(sut.fieldText(for: huge).isEmpty)
    }

    func test_input_overflowing_to_infinity_does_not_crash_the_field() {
        // A long enough digit run parses to .infinity, which traps identically.
        let overflowed = sut.fieldValue(from: String(repeating: "9", count: 400), for: .upper)
        XCTAssertEqual(overflowed, RangeSliderStyle.maximumFieldValue)
        XCTAssertFalse(sut.fieldText(for: overflowed).isEmpty)
    }

    func test_oversized_input_saturates_rather_than_clearing_the_field() {
        // Pinning at the ceiling keeps the field usable; returning nil would wipe what was typed.
        XCTAssertEqual(
            sut.fieldValue(from: String(repeating: "9", count: 19), for: .lower),
            RangeSliderStyle.maximumFieldValue
        )
    }

    func test_the_ceiling_survives_the_round_trip_through_text() {
        let capped = sut.fieldValue(from: String(repeating: "9", count: 30), for: .upper)
        let text = sut.fieldText(for: capped)
        XCTAssertEqual(sut.fieldValue(from: text, for: .upper), capped)
    }

    func test_a_non_finite_value_renders_empty_rather_than_trapping() {
        // Defence in depth: `fieldText` must survive a value that did not come through the parser.
        XCTAssertEqual(sut.fieldText(for: .infinity), "")
        XCTAssertEqual(sut.fieldText(for: .nan), "")
        XCTAssertEqual(sut.fieldText(for: 1e19), "")
    }

    // MARK: - Touch target

    func test_touch_target_meets_the_hig_minimum_without_growing_the_drawn_row() {
        XCTAssertGreaterThanOrEqual(RangeSliderStyle.touchTargetHeight, 44)
        XCTAssertEqual(RangeSliderStyle.trackHitHeight, 24, "The design draws a 24pt row")
    }
}
