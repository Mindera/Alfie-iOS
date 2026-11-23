import Model
import SharedUI
import XCTest
@testable import ProductListing

final class RefineViewModelTests: XCTestCase {
    // MARK: - Seeding from applied state

    func test_pending_state_starts_from_the_applied_filters() {
        let sut = makeSUT(appliedFilters: .init(maxPrice: 120, minPrice: 40), appliedSort: .priceAsc)
        XCTAssertEqual(sut.pendingMinPrice, 40)
        XCTAssertEqual(sut.pendingMaxPrice, 120)
        XCTAssertEqual(sut.pendingSort, .priceAsc)
    }

    func test_pending_state_starts_empty_when_nothing_is_applied() {
        let sut = makeSUT()
        XCTAssertNil(sut.pendingMinPrice)
        XCTAssertNil(sut.pendingMaxPrice)
        XCTAssertNil(sut.pendingSort, "No sort is pre-selected")
    }

    // MARK: - Apply

    func test_apply_forwards_the_pending_price_as_a_filter_input() {
        var applied: ProductFilterInput?
        let sut = makeSUT(onApply: { filters, _ in applied = filters })
        sut.pendingMinPrice = 40
        sut.pendingMaxPrice = 120

        sut.apply()

        XCTAssertEqual(applied?.minPrice, 40)
        XCTAssertEqual(applied?.maxPrice, 120)
    }

    func test_apply_forwards_nil_rather_than_an_empty_filter_when_nothing_is_set() {
        var applied: ProductFilterInput? = .init(minPrice: 1)
        var didApply = false
        let sut = makeSUT(onApply: { filters, _ in
            applied = filters
            didApply = true
        })

        sut.apply()

        XCTAssertTrue(didApply)
        XCTAssertNil(applied, "An unset filter must be omitted from the request, not sent empty")
    }

    func test_apply_forwards_one_sided_bounds() {
        var applied: ProductFilterInput?
        let sut = makeSUT(onApply: { filters, _ in applied = filters })
        sut.pendingMinPrice = 40

        sut.apply()

        XCTAssertEqual(applied?.minPrice, 40)
        XCTAssertNil(applied?.maxPrice, "A nil bound means no limit on that side")
    }

    func test_apply_forwards_the_pending_sort() {
        var applied: SortByType?
        let sut = makeSUT(onApply: { _, sort in applied = sort })
        sut.pendingSort = .priceDesc

        sut.apply()

        XCTAssertEqual(applied, .priceDesc)
    }

    func test_apply_is_blocked_while_the_range_is_invalid() {
        var didApply = false
        let sut = makeSUT(onApply: { _, _ in didApply = true })
        sut.pendingMinPrice = 200
        sut.pendingMaxPrice = 100

        sut.apply()

        XCTAssertFalse(didApply)
        XCTAssertFalse(sut.canApply)
    }

    // MARK: - Invalid range

    func test_a_crossed_range_is_invalid() {
        let sut = makeSUT()
        sut.pendingMinPrice = 200
        sut.pendingMaxPrice = 100
        XCTAssertTrue(sut.isPriceRangeInvalid)
    }

    func test_an_equal_range_is_valid() {
        // A single-price filter is a legitimate query, not an error.
        let sut = makeSUT()
        sut.pendingMinPrice = 100
        sut.pendingMaxPrice = 100
        XCTAssertFalse(sut.isPriceRangeInvalid)
    }

    func test_a_one_sided_range_is_never_invalid() {
        let sut = makeSUT()
        sut.pendingMinPrice = 900
        XCTAssertFalse(sut.isPriceRangeInvalid, "With no maximum there is nothing to cross")
    }

    // MARK: - Remove All

    func test_remove_all_clears_every_filter() {
        let sut = makeSUT(appliedFilters: .init(maxPrice: 120, minPrice: 40))
        sut.removeAllFilters()
        XCTAssertNil(sut.pendingMinPrice)
        XCTAssertNil(sut.pendingMaxPrice)
    }

    func test_remove_all_leaves_sort_alone() {
        // Sort is not a filter, and with no default selection, clearing it would strand the user
        // in a state the radio group cannot otherwise reach (ALFMOB-486).
        let sut = makeSUT(appliedFilters: .init(minPrice: 40), appliedSort: .alphaAsc)
        sut.removeAllFilters()
        XCTAssertEqual(sut.pendingSort, .alphaAsc)
    }

    func test_remove_all_does_not_apply_by_itself() {
        var didApply = false
        let sut = makeSUT(appliedFilters: .init(minPrice: 40), onApply: { _, _ in didApply = true })
        sut.removeAllFilters()
        XCTAssertFalse(didApply, "Remove All edits pending state; the CTA is still what applies")
    }

    func test_remove_all_is_offered_only_while_something_is_filtered() {
        let clean = makeSUT()
        XCTAssertFalse(clean.hasActiveFilters)

        let filtered = makeSUT(appliedFilters: .init(minPrice: 40))
        XCTAssertTrue(filtered.hasActiveFilters)
        filtered.removeAllFilters()
        XCTAssertFalse(filtered.hasActiveFilters)
    }

    func test_sort_alone_does_not_count_as_an_active_filter() {
        let sut = makeSUT(appliedSort: .priceAsc)
        XCTAssertFalse(sut.hasActiveFilters)
    }

    // MARK: - Currency affix

    func test_currency_symbol_is_derived_from_the_bounds_currency() {
        let sut = makeSUT(bounds: PriceFilterBounds(currencyCode: "GBP", minimum: 8, maximum: 480))
        XCTAssertEqual(sut.currencySymbol, CurrencyFormatter.symbol(for: "GBP"))
    }

    func test_there_is_no_currency_symbol_without_bounds() {
        XCTAssertNil(makeSUT(bounds: nil).currencySymbol)
    }

    // MARK: - Row summary

    func test_the_price_row_shows_no_summary_when_unfiltered() {
        XCTAssertNil(makeSUT().priceSummary)
    }

    func test_the_price_row_summarises_both_sides() {
        let sut = makeSUT()
        sut.pendingMinPrice = 40
        sut.pendingMaxPrice = 120
        let summary = sut.priceSummary
        XCTAssertTrue(summary?.contains("40") == true, "Got \(summary ?? "nil")")
        XCTAssertTrue(summary?.contains("120") == true, "Got \(summary ?? "nil")")
    }

    func test_the_price_row_summarises_a_one_sided_range() {
        let sut = makeSUT()
        sut.pendingMinPrice = 40
        XCTAssertTrue(sut.priceSummary?.contains("40") == true)
        XCTAssertFalse(sut.priceSummary?.contains("480") == true, "The unset side must not show a bound")
    }

    // MARK: - Oversized values (regression: Int(Double) trap)

    func test_a_price_too_large_for_Int_does_not_crash_the_row_summary() {
        let sut = makeSUT()
        sut.pendingMinPrice = 1e19
        XCTAssertNotNil(sut.priceSummary)
    }

    func test_a_non_finite_price_does_not_crash_the_row_summary() {
        // `Decimal(Double.infinity)` traps. Unreachable while every writer caps the pending
        // values, but the guard is what keeps that true if a new writer appears.
        let sut = makeSUT()
        sut.pendingMinPrice = .infinity
        XCTAssertNil(sut.priceSummary, "A non-finite bound contributes nothing rather than trapping")

        sut.pendingMaxPrice = 500
        XCTAssertNotNil(sut.priceSummary, "The finite side still summarises")
    }

    func test_the_row_summary_is_currency_formatted_not_interpolated() {
        // Interpolating the glyph hardcodes symbol-before-amount, which is wrong where the locale
        // suffixes it, and disagrees with what the slider announces to VoiceOver.
        let sut = makeSUT()
        sut.pendingMinPrice = 40
        let expected = CurrencyFormatter.string(amount: Decimal(40), currencyCode: "GBP")
        XCTAssertEqual(sut.priceSummary?.contains(expected), true, "Got \(sut.priceSummary ?? "nil")")
    }

    // MARK: - Late-arriving bounds

    func test_bounds_arriving_after_presentation_are_adopted() {
        // The bounds query races the product query and Refine is tappable throughout, so a sheet
        // opened first must still pick the bounds up rather than stranding the Price row.
        let sut = makeSUT(bounds: nil)
        XCTAssertNil(sut.currencySymbol)

        sut.priceBounds = PriceFilterBounds(currencyCode: "GBP", minimum: 8, maximum: 480)

        XCTAssertEqual(sut.currencySymbol, CurrencyFormatter.symbol(for: "GBP"))
    }

    // MARK: - Untouched filter dimensions

    func test_applying_price_preserves_dimensions_the_sheet_cannot_show() {
        var applied: ProductFilterInput?
        let sut = makeSUT(
            appliedFilters: .init(brandNames: ["Acme"], inventory: true, productTypes: ["Bags"]),
            onApply: { filters, _ in applied = filters }
        )
        sut.pendingMinPrice = 40

        sut.apply()

        XCTAssertEqual(applied?.minPrice, 40)
        XCTAssertEqual(applied?.brandNames, ["Acme"], "A price change must not drop an active brand filter")
        XCTAssertEqual(applied?.productTypes, ["Bags"])
        XCTAssertEqual(applied?.inventory, true)
    }

    func test_remove_all_clears_dimensions_the_sheet_cannot_show_too() {
        // ALFMOB-486: Remove All clears *every* filter, not just the visible ones.
        var applied: ProductFilterInput? = .init(minPrice: 1)
        let sut = makeSUT(
            appliedFilters: .init(brandNames: ["Acme"], minPrice: 40),
            onApply: { filters, _ in applied = filters }
        )

        sut.removeAllFilters()
        sut.apply()

        XCTAssertNil(applied)
    }

    func test_an_unshown_dimension_still_offers_remove_all() {
        let sut = makeSUT(appliedFilters: .init(brandNames: ["Acme"]))
        XCTAssertTrue(sut.hasActiveFilters)
    }

    // MARK: - Helpers

    private func makeSUT(
        bounds: PriceFilterBounds? = PriceFilterBounds(currencyCode: "GBP", minimum: 8, maximum: 480),
        appliedFilters: ProductFilterInput? = nil,
        appliedSort: SortByType? = nil,
        onApply: @escaping (ProductFilterInput?, SortByType?) -> Void = { _, _ in }
    ) -> RefineViewModel {
        RefineViewModel(
            priceBounds: bounds,
            appliedFilters: appliedFilters,
            appliedSort: appliedSort,
            onApply: onApply
        )
    }
}
