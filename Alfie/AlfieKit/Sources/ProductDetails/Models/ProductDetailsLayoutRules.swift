import Model
import SharedUI
import SwiftUI

/// Every layout and appearance rule for Product Details, in one pure place so the thresholds design
/// may revise live in one testable file rather than scattered across the view.
enum ProductDetailsLayoutRules {
    enum SizeLayout: Equatable {
        case chipGrid
        case verticalList
    }

    enum ColourLayout: Equatable {
        case summaryOnly
        case inlineGrid
        case sheet
    }

    enum StockMessage: Equatable {
        case none
        case lastOne
        case lastUnits
    }

    private enum Constants {
        /// Beyond this count a selector stops rendering inline. Reuses the count the pre-redesign
        /// screen used to collapse into a sheet, so the cut-over point is unchanged.
        static let inlineItemLimit = 6
        /// ASSUMPTION: design has not confirmed this N — see to-questionnaire-pdp-control-behaviour.md.
        static let lowStockThreshold = 5
        static let borderWidthDefault: CGFloat = 1
        static let borderWidthSelected: CGFloat = 2
    }

    static func sizeLayout(forSizeCount count: Int) -> SizeLayout {
        count > Constants.inlineItemLimit ? .verticalList : .chipGrid
    }

    static func colourLayout(forColourCount count: Int) -> ColourLayout {
        guard count > 1 else {
            return .summaryOnly
        }
        return count > Constants.inlineItemLimit ? .sheet : .inlineGrid
    }

    /// Colours other than the selected one, for the info block's `+N` summary. `nil` hides the
    /// summary — single-colour and no-colour products have nothing to choose between, and a product
    /// whose selected variant carries no colour has no swatch to show.
    ///
    /// Derived from `colourLayout` rather than restating its threshold, so the summary and the
    /// picker it opens cannot drift apart.
    static func colourSummaryRemainingCount(forColourCount count: Int, hasSelection: Bool) -> Int? {
        guard hasSelection, colourLayout(forColourCount: count) != .summaryOnly else {
            return nil
        }
        return count - 1
    }

    static func stockMessage(forAvailable available: Int?) -> StockMessage {
        guard let available, available > 0 else {
            return .none
        }
        if available == 1 {
            return .lastOne
        }
        return available <= Constants.lowStockThreshold ? .lastUnits : .none
    }
}

// MARK: - Size swatch appearance

extension ProductDetailsLayoutRules {
    /// Resolved appearance of a single size swatch. Selection is a heavier *border* — never a fill —
    /// which is a behavioural change from the pre-redesign component.
    struct SizeSwatchAppearance: Equatable {
        let borderColor: Color
        let borderWidth: CGFloat
        let textColor: Color
        let backgroundColor: Color
        let isStruckThrough: Bool
    }

    static func sizeSwatchAppearance(
        for state: SizingSwatch.ItemState,
        isSelected: Bool
    ) -> SizeSwatchAppearance {
        guard state == .available else {
            return .init(
                borderColor: Theme.contentContentTerciary,
                borderWidth: Constants.borderWidthDefault,
                textColor: Theme.contentContentTerciary,
                backgroundColor: .clear,
                isStruckThrough: state == .outOfStock
            )
        }

        // TOKEN GAP (G1): the design's unselected border is #CDCDCD, which has no `Theme.*` alias —
        // `border/border-strong` is requested upstream. Until it lands this holds the pre-redesign
        // colour so this ticket changes no pixels; the size-selector ticket flips it.
        return .init(
            borderColor: Theme.contentContentPrimary,
            borderWidth: isSelected ? Constants.borderWidthSelected : Constants.borderWidthDefault,
            textColor: Theme.contentContentPrimary,
            backgroundColor: .clear,
            isStruckThrough: false
        )
    }
}
