import Model

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
        ColorSwatch(
            id: colour.id,
            name: colour.name,
            type: colour.swatch.map { .url($0.url) },
            isDisabled: !isAvailable
        )
    }
}

private extension VariantSelection.SizeOption {
    var sizingSwatch: SizingSwatch {
        SizingSwatch(id: size.id, name: size.displayName, state: isInStock ? .available : .outOfStock)
    }
}
