import Foundation

/// Both PDP selection axes as one value, ready to draw.
///
/// The swatches and the highlight are produced together from one derivation, so the screen cannot
/// show a colour as selected that the chosen variant does not have.
public struct VariantSelectionState {
    public enum SizeDisplay: Equatable {
        /// A real choice: the grid, with sold-out chips drawn disabled rather than dropped. A
        /// shopper who cannot buy their size needs to see that it is theirs that is gone.
        case selector
        /// One size, already selected, so there is nothing to pick — only to name.
        case single(name: String)
        /// No size axis at all.
        case oneSize
    }

    public let colours: [ColorSwatch]
    public let selectedColour: ColorSwatch?
    public let sizes: [SizingSwatch]
    public let selectedSize: SizingSwatch?

    public init(
        colours: [ColorSwatch] = [],
        selectedColour: ColorSwatch? = nil,
        sizes: [SizingSwatch] = [],
        selectedSize: SizingSwatch? = nil
    ) {
        self.colours = colours
        self.selectedColour = selectedColour
        self.sizes = sizes
        self.selectedSize = selectedSize
    }

    /// Driven by how many sizes there are, never by whether any of them are in stock: stock decides
    /// how a chip is drawn, not whether the shopper is told the size exists.
    public var sizeDisplay: SizeDisplay {
        guard let only = sizes.first else {
            return .oneSize
        }
        return sizes.count == 1 ? .single(name: only.name) : .selector
    }
}
