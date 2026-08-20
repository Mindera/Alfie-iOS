import SharedUI

/// Every layout rule for Product Details, in one pure place so the thresholds design may revise
/// live in one testable file rather than scattered across the view.
enum ProductDetailsLayoutRules {
    enum ColourLayout: Equatable {
        case summaryOnly
        case inlineGrid
    }

    /// Every product with something to choose between picks inline. The long-run case used to
    /// collapse into a bottom sheet; the design has no such sheet, so the grid simply grows.
    static func colourLayout(forColourCount count: Int) -> ColourLayout {
        count > 1 ? .inlineGrid : .summaryOnly
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

    /// The `Black | Ref. 0273/393` line beneath the description, and how VoiceOver should speak it.
    struct DescriptionMetadata: Equatable {
        let display: String
        /// The pipe is a layout glyph — VoiceOver either spells it out or drops it, running the two
        /// facts together — so speech gets a comma instead.
        let accessibilityLabel: String
    }

    /// Each present half is rendered by a localised string of its own, so translators own the
    /// separator and the order — joining in code would not survive a locale that punctuates or
    /// orders differently. `nil` when neither half exists, so the line is omitted entirely.
    static func descriptionMetadata(colourName: String?, reference: String?) -> DescriptionMetadata? {
        switch (colourName, reference) {
        case let (colourName?, reference?):
            return .init(
                display: L10n.Pdp.DescriptionMetadata.colourAndReference(colourName, reference),
                accessibilityLabel: L10n.Pdp.DescriptionMetadata.accessibilityLabel(colourName, reference)
            )
        case let (colourName?, nil):
            return .init(display: colourName, accessibilityLabel: colourName)
        case let (nil, reference?):
            let reference = L10n.Pdp.ProductReference.value(reference)
            return .init(display: reference, accessibilityLabel: reference)
        case (nil, nil):
            return nil
        }
    }
}
