import Model
import SharedUI

extension ProductDetailsViewModel {
    public func didSelectColour(_ swatch: ColorSwatch) {
        updateSelection(selection.selecting(colourID: swatch.id))
    }

    public func didSelectSize(_ swatch: SizingSwatch) {
        updateSelection(selection.selecting(sizeID: swatch.id))
    }

    func selection(for product: Product) -> VariantSelection {
        guard let restored = restoredVariant(in: product) else {
            return VariantSelection(variants: product.variants, preferredVariant: product.defaultVariant)
        }
        return VariantSelection(variants: product.variants, restoring: restored)
    }

    /// The one way to move the selection, so the drawn state can never lag behind it.
    func updateSelection(_ selection: VariantSelection) {
        // `@Published` publishes on every set, equal or not, and re-picking the current swatch
        // lands an identical selection. The guard sits on the source so that anything moving the
        // variants — a refetch carrying fresh stock — still reaches the swatches.
        guard selection != self.selection else { return }

        self.selection = selection
        let colours = selection.colours.map(\.swatch)
        let sizes = selection.sizes.map(\.swatch)
        variantSelection = VariantSelectionState(
            colours: colours,
            selectedColour: colours.first { $0.id == selection.selectedColour?.id },
            sizes: sizes,
            selectedSize: sizes.first { $0.id == selection.selectedSize?.id }
        )
        displayVariant = selection.displayVariant
        addToBagState = switch selection.purchaseState {
        case .ready:
            .ready

        case .needsSize:
            .needsSize

        case .outOfStock:
            .outOfStock
        }
    }

    /// When re-entering from Bag/Wishlist (`.selectedProduct`) the persisted variant carries a stale
    /// snapshot (e.g. out-of-date stock), so map the shopper's choice onto the freshly fetched
    /// product by `sku` — keeping what they chose while reflecting current stock and price. A deep
    /// link's `sku` (a scanned Alfie code) is mapped the same way, then a scanned Barcode's
    /// `variantId`. Nil when nothing was requested, or the product no longer offers it, which leaves
    /// the fresh-open path to seed the colour from merchandising.
    private func restoredVariant(in product: Product) -> Product.Variant? {
        if let requestedSku, let variant = product.variants.first(where: { $0.sku == requestedSku }) {
            return variant
        }
        if let requestedVariantId, let variant = product.variants.first(where: { $0.id == requestedVariantId }) {
            return variant
        }
        return nil
    }
}

private extension VariantSelection.ColourOption {
    var swatch: ColorSwatch {
        let type: SwatchType = if let url = colour.swatch?.url {
            .url(url)
        } else {
            // A filled stand-in for a missing swatch image, so it reads as a surface token.
            .color(Theme.surfaceBackgroundInvertedPrimary)
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
    var swatch: SizingSwatch {
        SizingSwatch(id: size.id, name: size.displayName, state: isInStock ? .available : .outOfStock)
    }
}
