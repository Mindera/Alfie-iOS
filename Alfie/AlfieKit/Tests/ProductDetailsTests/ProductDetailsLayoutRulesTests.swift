import XCTest
@testable import ProductDetails

final class ProductDetailsLayoutRulesTests: XCTestCase {
    // MARK: - Colour layout

    func test_colour_layout_is_summary_only_when_there_is_nothing_to_choose() {
        XCTAssertEqual(ProductDetailsLayoutRules.colourLayout(forColourCount: 0), .summaryOnly)
        XCTAssertEqual(ProductDetailsLayoutRules.colourLayout(forColourCount: 1), .summaryOnly)
    }

    func test_colour_layout_is_inline_grid_up_to_the_inline_limit() {
        XCTAssertEqual(ProductDetailsLayoutRules.colourLayout(forColourCount: 2), .inlineGrid)
        XCTAssertEqual(ProductDetailsLayoutRules.colourLayout(forColourCount: 6), .inlineGrid)
    }

    func test_colour_layout_is_sheet_above_the_inline_limit() {
        XCTAssertEqual(ProductDetailsLayoutRules.colourLayout(forColourCount: 7), .sheet)
    }

    // MARK: - Colour summary

    func test_colour_summary_is_hidden_when_there_is_nothing_to_choose() {
        XCTAssertNil(ProductDetailsLayoutRules.colourSummaryRemainingCount(forColourCount: 0, hasSelection: true))
        XCTAssertNil(ProductDetailsLayoutRules.colourSummaryRemainingCount(forColourCount: 1, hasSelection: true))
    }

    func test_colour_summary_counts_every_colour_but_the_selected_one() {
        XCTAssertEqual(ProductDetailsLayoutRules.colourSummaryRemainingCount(forColourCount: 2, hasSelection: true), 1)
        XCTAssertEqual(ProductDetailsLayoutRules.colourSummaryRemainingCount(forColourCount: 4, hasSelection: true), 3)
    }

    func test_colour_summary_is_hidden_without_a_selected_colour() {
        // The converter leaves the selection nil when the variant carries no colour; there is then
        // no swatch to summarise. The view owes that case its own entry point to the sheet.
        XCTAssertNil(ProductDetailsLayoutRules.colourSummaryRemainingCount(forColourCount: 4, hasSelection: false))
    }

    func test_colour_summary_is_shown_whenever_a_colour_picker_would_be_and_a_colour_is_selected() {
        // The summary is the entry point to the picker, so the two must never disagree.
        for count in 0...20 {
            let hasSummary = ProductDetailsLayoutRules.colourSummaryRemainingCount(
                forColourCount: count,
                hasSelection: true
            ) != nil
            let hasPicker = ProductDetailsLayoutRules.colourLayout(forColourCount: count) != .summaryOnly
            XCTAssertEqual(hasSummary, hasPicker, "diverged at \(count)")
        }
    }

    /// Without a selection the summary disappears at every count, so nothing it returns can be the
    /// sheet's entry point — the gap this sweep pins is why the view draws its own row for that case.
    func test_colour_summary_is_never_the_entry_point_without_a_selection() {
        for count in 0...20 {
            XCTAssertNil(
                ProductDetailsLayoutRules.colourSummaryRemainingCount(forColourCount: count, hasSelection: false),
                "summarised at \(count)"
            )
        }
    }
}
