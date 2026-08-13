/// Every layout rule for Product Details, in one pure place so the thresholds design may revise
/// live in one testable file rather than scattered across the view.
enum ProductDetailsLayoutRules {
    enum ColourLayout: Equatable {
        case summaryOnly
        case inlineGrid
        case sheet
    }

    private enum Constants {
        /// Beyond this count the colour selector stops rendering inline. Reuses the count the
        /// pre-redesign screen used to collapse into a sheet, so the cut-over point is unchanged.
        static let inlineItemLimit = 6
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
}
