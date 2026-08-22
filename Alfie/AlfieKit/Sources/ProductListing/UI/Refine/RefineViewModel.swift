import Combine
import Foundation
import Model
import SharedUI

// MARK: - RefineViewModelProtocol

protocol RefineViewModelProtocol: ObservableObject {
    var priceBounds: PriceFilterBounds? { get }
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
    let priceBounds: PriceFilterBounds?

    @Published var pendingMinPrice: Double?
    @Published var pendingMaxPrice: Double?
    @Published var pendingSort: SortByType?

    private let onApply: (ProductFilterInput?, SortByType?) -> Void

    init(
        priceBounds: PriceFilterBounds?,
        appliedFilters: ProductFilterInput?,
        appliedSort: SortByType?,
        onApply: @escaping (ProductFilterInput?, SortByType?) -> Void
    ) {
        self.priceBounds = priceBounds
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
    var hasActiveFilters: Bool {
        pendingMinPrice != nil || pendingMaxPrice != nil
    }

    /// The glyph the price fields show as their affix. Derived from the BFF's currency code, not
    /// the `$` the Figma panel draws — the PLP it filters is priced in the store's own currency.
    var currencySymbol: String? {
        priceBounds.map { CurrencyFormatter.symbol(for: $0.currencyCode) }
    }

    /// Trailing summary on the Price row; nil when the dimension is unfiltered.
    var priceSummary: String? {
        guard let symbol = currencySymbol, hasActiveFilters else { return nil }
        let minimum = pendingMinPrice.map { "\(symbol)\(Int($0))" }
        let maximum = pendingMaxPrice.map { "\(symbol)\(Int($0))" }
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
    }

    func apply() {
        guard canApply else { return }
        onApply(filterInput, pendingSort)
    }

    /// `nil` when no dimension is set, so the field is omitted from the request entirely rather
    /// than sent as an empty filter object.
    private var filterInput: ProductFilterInput? {
        guard hasActiveFilters else { return nil }
        return ProductFilterInput(maxPrice: pendingMaxPrice, minPrice: pendingMinPrice)
    }
}
