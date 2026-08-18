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

    // MARK: - Description metadata

    func test_description_metadata_joins_both_halves_through_a_localised_string() {
        let metadata = ProductDetailsLayoutRules.descriptionMetadata(colourName: "Black", reference: "0273/393")

        XCTAssertEqual(metadata?.display, "Black | Ref. 0273/393")
    }

    func test_description_metadata_speaks_a_comma_rather_than_the_pipe() {
        let metadata = ProductDetailsLayoutRules.descriptionMetadata(colourName: "Black", reference: "0273/393")

        XCTAssertEqual(metadata?.accessibilityLabel, "Black, Ref. 0273/393")
    }

    func test_description_metadata_drops_the_separator_when_only_the_colour_exists() {
        let metadata = ProductDetailsLayoutRules.descriptionMetadata(colourName: "Black", reference: nil)

        XCTAssertEqual(metadata?.display, "Black")
        XCTAssertEqual(metadata?.accessibilityLabel, "Black")
    }

    func test_description_metadata_drops_the_separator_when_only_the_reference_exists() {
        let metadata = ProductDetailsLayoutRules.descriptionMetadata(colourName: nil, reference: "0273/393")

        XCTAssertEqual(metadata?.display, "Ref. 0273/393")
        XCTAssertEqual(metadata?.accessibilityLabel, "Ref. 0273/393")
    }

    func test_description_metadata_is_omitted_when_neither_half_exists() {
        XCTAssertNil(ProductDetailsLayoutRules.descriptionMetadata(colourName: nil, reference: nil))
    }
}
