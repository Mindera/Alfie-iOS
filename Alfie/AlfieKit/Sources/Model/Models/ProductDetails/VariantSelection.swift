import Foundation

/// The PDP's colour × size matrix as one value.
///
/// The chosen colour and size are the only state; the variant, the chip availability and whether
/// the product can be bought are all derived from them here. Because the highlight and the variant
/// come out of the same derivation, they cannot disagree.
///
/// Every size question is scoped to the selected colour. A size sold out in Sand is out of stock
/// even when Navy still has it.
public struct VariantSelection: Equatable {
    public struct ColourOption: Equatable {
        public let colour: Product.Colour
        /// False only when no variant of this colour has any stock in any size, which is the one
        /// case the grid disables. A colour missing the *selected* size stays available and
        /// tappable — colour is the axis shoppers browse, so it is never gated on an incidental
        /// size.
        public let isAvailable: Bool
    }

    public struct SizeOption: Equatable {
        public let size: Product.ProductSize
        public let isInStock: Bool
    }

    /// Why the product can or cannot be bought right now, as one answer rather than a variant plus
    /// a set of rules about when to trust it.
    public enum PurchaseState: Equatable {
        case ready(Product.Variant)
        case needsSize
        case outOfStock

        /// The variant a cart write can name, and nil whenever there is not exactly one.
        public var readyVariant: Product.Variant? {
            guard case .ready(let variant) = self else {
                return nil
            }
            return variant
        }
    }

    private let variants: [Product.Variant]
    public private(set) var selectedColour: Product.Colour?
    public private(set) var selectedSize: Product.ProductSize?

    /// Colour is always seeded — to `preferredVariant`'s colour where the product offers it, to the
    /// first colour otherwise. A single size is seeded too, so "is a size selected?" has one answer.
    public init(variants: [Product.Variant], preferredVariant: Product.Variant? = nil) {
        let colours = Self.distinctColours(in: variants)
        let colour = colours.first { $0.id == preferredVariant?.colour?.id } ?? colours.first

        self.init(variants: variants, selectedColour: colour, selectedSize: nil)
        selectedSize = soleSize
    }

    private init(variants: [Product.Variant], selectedColour: Product.Colour?, selectedSize: Product.ProductSize?) {
        self.variants = variants
        self.selectedColour = selectedColour
        self.selectedSize = selectedSize
    }

    public var colours: [ColourOption] {
        Self.distinctColours(in: variants).map { colour in
            ColourOption(
                colour: colour,
                isAvailable: variants.contains { $0.colour?.id == colour.id && $0.stock > 0 }
            )
        }
    }

    public var sizes: [SizeOption] {
        let scoped = variantsForSelectedColour
        var seen = Set<String>()
        return scoped.compactMap { variant in
            guard let size = variant.size, seen.insert(size.id).inserted else {
                return nil
            }
            return SizeOption(
                size: size,
                isInStock: scoped.contains { $0.size?.id == size.id && $0.stock > 0 }
            )
        }
    }

    /// What the gallery, share sheet and description metadata read. Follows the colour on its own,
    /// and narrows to the exact variant once a size is chosen.
    public var displayVariant: Product.Variant? {
        if let selectedSize,
           let exact = variantsForSelectedColour.first(where: { $0.size?.id == selectedSize.id }) {
            return exact
        }

        return variantsForSelectedColour.first ?? variants.first
    }

    public var purchaseState: PurchaseState {
        guard selectedSize != nil || sizes.isEmpty else {
            return .needsSize
        }

        // `.ready` requires the selection to resolve to exactly one variant: where it cannot
        // identify what it is selling, it declines rather than picking arbitrarily.
        let matches = variantsForSelectedColour.filter { $0.size?.id == selectedSize?.id }
        guard
            matches.count == 1,
            let variant = matches.first,
            variant.id != nil,
            variant.stock > 0
        else {
            return .outOfStock
        }

        return .ready(variant)
    }

    public func selecting(colourID: String) -> Self {
        guard let colour = Self.distinctColours(in: variants).first(where: { $0.id == colourID }) else {
            return self
        }

        var next = Self(variants: variants, selectedColour: colour, selectedSize: nil)
        // Keep the size only where the new colour stocks it; never snap to a nearest size.
        let kept = next.sizes.first { $0.size.id == selectedSize?.id && $0.isInStock }?.size
        next.selectedSize = kept ?? next.soleSize
        return next
    }

    public func selecting(sizeID: String) -> Self {
        guard let size = sizes.first(where: { $0.size.id == sizeID })?.size else {
            return self
        }
        return Self(variants: variants, selectedColour: selectedColour, selectedSize: size)
    }

    // MARK: - Private

    private var variantsForSelectedColour: [Product.Variant] {
        variants.filter { $0.colour?.id == selectedColour?.id }
    }

    /// A lone size is implicit, so it is chosen for the shopper — out of stock included, so the CTA
    /// can say "out of stock" rather than asking for a size there is no choice about.
    private var soleSize: Product.ProductSize? {
        let options = sizes
        return options.count == 1 ? options.first?.size : nil
    }

    /// Distinct colours in the order the BFF returned the variants, which is the merchandising
    /// order and not necessarily ascending by id.
    private static func distinctColours(in variants: [Product.Variant]) -> [Product.Colour] {
        var seen = Set<String>()
        return variants.compactMap { variant in
            guard let colour = variant.colour, seen.insert(colour.id).inserted else {
                return nil
            }
            return colour
        }
    }
}
