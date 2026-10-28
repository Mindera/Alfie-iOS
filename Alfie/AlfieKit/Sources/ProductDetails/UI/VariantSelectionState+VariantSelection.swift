import Model
import SharedUI

extension VariantSelectionState {
    init(_ selection: VariantSelection) {
        let colours = selection.colours.map(\.colorSwatch)
        let sizes = selection.sizes.map(\.sizingSwatch)
        self.init(
            colours: colours,
            selectedColour: colours.first { $0.id == selection.selectedColour?.id },
            sizes: sizes,
            selectedSize: sizes.first { $0.id == selection.selectedSize?.id }
        )
    }
}

private extension VariantSelection.ColourOption {
    var colorSwatch: ColorSwatch {
        let type: SwatchType = if let url = colour.swatch?.url {
            .url(url)
        } else {
            // A filled stand-in for a missing swatch image, so it reads as a surface token.
            .color(DesignSystem.shared.color.surfaceBackgroundInvertedPrimary)
        }

        return ColorSwatch(
            id: colour.id,
            name: colour.name,
            type: type,
            isDisabled: !isAvailable
        )
    }
}

private extension VariantSelection.SizeOption {
    var sizingSwatch: SizingSwatch {
        SizingSwatch(id: size.id, name: size.displayName, state: isInStock ? .available : .outOfStock)
    }
}
