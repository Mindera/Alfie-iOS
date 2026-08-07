import Model
import SharedUI
import SwiftUI
import XCTest
@testable import ProductDetails

final class ProductDetailsLayoutRulesTests: XCTestCase {
    // MARK: - Size layout

    func test_size_layout_is_chip_grid_at_and_below_the_inline_limit() {
        XCTAssertEqual(ProductDetailsLayoutRules.sizeLayout(forSizeCount: 1), .chipGrid)
        XCTAssertEqual(ProductDetailsLayoutRules.sizeLayout(forSizeCount: 6), .chipGrid)
    }

    func test_size_layout_is_vertical_list_above_the_inline_limit() {
        XCTAssertEqual(ProductDetailsLayoutRules.sizeLayout(forSizeCount: 7), .verticalList)
        XCTAssertEqual(ProductDetailsLayoutRules.sizeLayout(forSizeCount: 24), .verticalList)
    }

    func test_size_layout_handles_empty_and_zero() {
        XCTAssertEqual(ProductDetailsLayoutRules.sizeLayout(forSizeCount: 0), .chipGrid)
    }

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

    func test_colour_layout_mirrors_the_size_threshold() {
        // The two selectors are specified to cut over at the same count; pin that they stay in step.
        for count in 2...20 {
            let coloursAreInline = ProductDetailsLayoutRules.colourLayout(forColourCount: count) == .inlineGrid
            let sizesAreInline = ProductDetailsLayoutRules.sizeLayout(forSizeCount: count) == .chipGrid
            XCTAssertEqual(coloursAreInline, sizesAreInline, "diverged at \(count)")
        }
    }

    // MARK: - Low stock message

    func test_stock_message_is_none_when_stock_is_unknown() {
        XCTAssertEqual(ProductDetailsLayoutRules.stockMessage(forAvailable: nil), StockMessage.none)
    }

    func test_stock_message_is_none_when_out_of_stock() {
        XCTAssertEqual(ProductDetailsLayoutRules.stockMessage(forAvailable: 0), StockMessage.none)
    }

    func test_stock_message_is_none_for_negative_stock() {
        XCTAssertEqual(ProductDetailsLayoutRules.stockMessage(forAvailable: -3), StockMessage.none)
    }

    func test_stock_message_is_last_one_for_exactly_one() {
        XCTAssertEqual(ProductDetailsLayoutRules.stockMessage(forAvailable: 1), StockMessage.lastOne)
    }

    func test_stock_message_is_last_units_between_two_and_the_threshold() {
        XCTAssertEqual(ProductDetailsLayoutRules.stockMessage(forAvailable: 2), StockMessage.lastUnits)
        XCTAssertEqual(ProductDetailsLayoutRules.stockMessage(forAvailable: 5), StockMessage.lastUnits)
    }

    func test_stock_message_is_none_above_the_threshold() {
        XCTAssertEqual(ProductDetailsLayoutRules.stockMessage(forAvailable: 6), StockMessage.none)
        XCTAssertEqual(ProductDetailsLayoutRules.stockMessage(forAvailable: 500), StockMessage.none)
    }

    // MARK: - Size swatch appearance

    func test_selection_is_a_border_and_never_a_fill() {
        // The pre-redesign component filled the swatch black when selected. This is the assertion
        // that pins the change, so a regression to a fill fails here rather than at design review.
        let selected = ProductDetailsLayoutRules.sizeSwatchAppearance(for: .available, isSelected: true)
        XCTAssertEqual(selected.backgroundColor, .clear)
    }

    func test_selected_swatch_has_a_heavier_border_than_unselected() {
        let selected = ProductDetailsLayoutRules.sizeSwatchAppearance(for: .available, isSelected: true)
        let unselected = ProductDetailsLayoutRules.sizeSwatchAppearance(for: .available, isSelected: false)
        XCTAssertGreaterThan(selected.borderWidth, unselected.borderWidth)
    }

    func test_available_swatch_text_is_content_primary() {
        let sut = ProductDetailsLayoutRules.sizeSwatchAppearance(for: .available, isSelected: false)
        XCTAssertEqual(sut.textColor, Theme.contentContentPrimary)
    }

    func test_out_of_stock_swatch_is_struck_through_and_dimmed() {
        let sut = ProductDetailsLayoutRules.sizeSwatchAppearance(for: .outOfStock, isSelected: false)
        XCTAssertTrue(sut.isStruckThrough)
        XCTAssertEqual(sut.textColor, Theme.contentContentTerciary)
    }

    func test_unavailable_swatch_is_dimmed_but_not_struck_through() {
        let sut = ProductDetailsLayoutRules.sizeSwatchAppearance(for: .unavailable, isSelected: false)
        XCTAssertFalse(sut.isStruckThrough)
        XCTAssertEqual(sut.textColor, Theme.contentContentTerciary)
    }

    func test_unavailable_states_never_fill_even_when_selected() {
        for state in [SizingSwatch.ItemState.outOfStock, .unavailable] {
            let sut = ProductDetailsLayoutRules.sizeSwatchAppearance(for: state, isSelected: true)
            XCTAssertEqual(sut.backgroundColor, .clear, "\(state) filled when selected")
        }
    }
}

private typealias StockMessage = ProductDetailsLayoutRules.StockMessage
