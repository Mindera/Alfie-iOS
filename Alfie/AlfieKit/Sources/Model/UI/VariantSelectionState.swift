import Foundation

/// Both PDP selection axes as one value, ready to draw.
///
/// The swatches and the highlight are produced together from one derivation, so the screen cannot
/// show a colour as selected that the chosen variant does not have.
public struct VariantSelectionState: Equatable {
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

    /// Whether to offer an interactive size choice. One size or none is implicit and already
    /// selected, so there is nothing to pick.
    public var canShowSizeSelector: Bool { sizes.count > 1 }
}
