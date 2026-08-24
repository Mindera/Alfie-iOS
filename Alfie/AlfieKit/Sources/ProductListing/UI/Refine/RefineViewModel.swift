import Combine
import Foundation
import Model
import SharedUI

// MARK: - RefineViewModelProtocol

protocol RefineViewModelProtocol: ObservableObject {
    var priceBounds: PriceFilterBounds? { get set }
    var pendingMinPrice: Double? { get set }
    var pendingMaxPrice: Double? { get set }
    var pendingSort: SortByType? { get set }
    var isPriceRangeInvalid: Bool { get }
    var canApply: Bool { get }
    var hasActiveFilters: Bool { get }
    var currencySymbol: String? { get }
    var priceSummary: String? { get }
    func removeAllFilters()
    func apply()
}

// MARK: - RefineViewModel

/// Owns the Refine sheet's **pending** state. Selections mutate it immediately and
/// back-navigation between sub-screens never commits; only `apply()` reaches the listing
/// (ALFMOB-476). Created fresh per presentation, so dismissing discards everything pending.
final class RefineViewModel: RefineViewModelProtocol {
    /// Settable because the bounds query races the product query, and the Refine button is live
    /// while the listing is still loading. Opening the sheet first would otherwise snapshot `nil`
    /// for the whole presentation and strand the Price row — the fetch is once-only, so it could
    /// not recover without dismissing.
    @Published var priceBounds: PriceFilterBounds?

    @Published var pendingMinPrice: Double?
    @Published var pendingMaxPrice: Double?
    @Published var pendingSort: SortByType?

    /// Dimensions this sheet does not expose. Carried through untouched so applying Price or Sort
    /// cannot silently drop a filter set elsewhere once a second dimension lands. Mutable only so
    /// Remove All can clear them too.
    private var carriedFilters: ProductFilterInput?
    private let onApply: (ProductFilterInput?, SortByType?) -> Void

    init(
        priceBounds: PriceFilterBounds?,
        appliedFilters: ProductFilterInput?,
        appliedSort: SortByType?,
        onApply: @escaping (ProductFilterInput?, SortByType?) -> Void
    ) {
        self.priceBounds = priceBounds
        carriedFilters = appliedFilters
        self.onApply = onApply
        pendingMinPrice = appliedFilters?.minPrice
        pendingMaxPrice = appliedFilters?.maxPrice
        pendingSort = appliedSort
    }

    /// A crossed range is surfaced as an inline error rather than silently clamped, so the user
    /// sees which of the two numbers they need to change (ALFMOB-481).
    var isPriceRangeInvalid: Bool {
        guard let minimum = pendingMinPrice, let maximum = pendingMaxPrice else { return false }
        return minimum > maximum
    }

    var canApply: Bool {
        !isPriceRangeInvalid
    }

    /// Drives whether Remove All is shown at all — it is hidden while there is nothing to remove.
    /// Counts dimensions this sheet cannot display, so Remove All still offers to clear them.
    var hasActiveFilters: Bool {
        pendingMinPrice != nil || pendingMaxPrice != nil || carriedFilters?.hasNonPriceDimension == true
    }

    /// The glyph the price fields show as their affix. Derived from the BFF's currency code, not
    /// the `$` the Figma panel draws — the PLP it filters is priced in the store's own currency.
    var currencySymbol: String? {
        priceBounds.map { CurrencyFormatter.symbol(for: $0.currencyCode) }
    }

    /// Trailing summary on the Price row; nil when the dimension is unfiltered.
    ///
    /// Formatted through `CurrencyFormatter` rather than interpolating the glyph: interpolation
    /// hardcodes symbol-before-amount, which is wrong in locales that suffix it, and `Int($0)`
    /// traps for values the unbounded field can hold. This is also what the slider announces to
    /// VoiceOver, so the row and the slider can no longer disagree.
    var priceSummary: String? {
        guard let currencyCode = priceBounds?.currencyCode, hasActiveFilters else { return nil }
        let format = { (value: Double) in
            CurrencyFormatter.string(amount: Decimal(value), currencyCode: currencyCode)
        }
        let minimum = pendingMinPrice.map(format)
        let maximum = pendingMaxPrice.map(format)
        switch (minimum, maximum) {
        case (let minimum?, let maximum?):
            return L10n.Plp.Refine.Price.Summary.between(minimum, maximum)
        case (let minimum?, nil):
            return L10n.Plp.Refine.Price.Summary.from(minimum)
        case (nil, let maximum?):
            return L10n.Plp.Refine.Price.Summary.upTo(maximum)
        case (nil, nil):
            return nil
        }
    }

    /// Clears every filter. Sort is deliberately untouched — it is not a filter, and with no
    /// default selection, clearing it would strand the user in a state the radio group cannot
    /// otherwise reach (ALFMOB-486). Edits pending state, so the CTA still has to be tapped.
    func removeAllFilters() {
        pendingMinPrice = nil
        pendingMaxPrice = nil
        // "Every filter", per ALFMOB-486 — including dimensions this sheet cannot display.
        carriedFilters = nil
    }

    func apply() {
        guard canApply else { return }
        onApply(filterInput, pendingSort)
    }

    /// `nil` when no dimension is set, so the field is omitted from the request entirely rather
    /// than sent as an empty filter object. Price is replaced from pending state; every other
    /// dimension is carried through as applied.
    private var filterInput: ProductFilterInput? {
        guard hasActiveFilters else { return nil }
        return ProductFilterInput(
            brandNames: carriedFilters?.brandNames,
            inventory: carriedFilters?.inventory,
            maxPrice: pendingMaxPrice,
            metafields: carriedFilters?.metafields,
            minPrice: pendingMinPrice,
            productTypes: carriedFilters?.productTypes
        )
    }
}

private extension ProductFilterInput {
    /// Dimensions the Refine sheet has no row for. Price is excluded because pending state owns it.
    var hasNonPriceDimension: Bool {
        brandNames?.isEmpty == false
            || productTypes?.isEmpty == false
            || metafields?.isEmpty == false
            || inventory != nil
    }
}
