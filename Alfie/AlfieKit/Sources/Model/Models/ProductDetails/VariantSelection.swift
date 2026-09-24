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

    /// Opening the PDP fresh. `preferredVariant` is the product's default, which is merchandising
    /// rather than anything the shopper picked — so it seeds the colour but never the size, and a
    /// default that cannot be bought gives way to a colour that can, instead of opening on a grid
    /// where every chip is disabled. A lone size is still seeded, so "is a size selected?" has one
    /// answer.
    public init(variants: [Product.Variant], preferredVariant: Product.Variant? = nil) {
        let preferred = Self.colour(preferredVariant?.colour?.id, in: variants)
        let buyable = preferred.flatMap { Self.hasStock($0, in: variants) ? $0 : nil }

        self.init(variants: variants, colour: buyable ?? Self.firstBuyableColour(in: variants), size: nil)
    }

    /// Re-entering from Bag or Wishlist. `saved` is the shopper's own choice, so both of its axes
    /// come back: the PDP lands on the variant that was saved rather than on whichever size happens
    /// to come first in that colour.
    public init(variants: [Product.Variant], restoring saved: Product.Variant) {
        // The saved colour stands even where it sold out. Moving the shopper off what they chose
        // hides that it sold out; keeping it lets the CTA say so.
        let colour = Self.colour(saved.colour?.id, in: variants) ?? Self.firstBuyableColour(in: variants)

        self.init(variants: variants, colour: colour, size: saved.size)
    }

    private init(variants: [Product.Variant], colour: Product.Colour?, size: Product.ProductSize?) {
        let options = Self.sizeOptions(in: variants, colour: colour)
        let restored = options.first { $0.size.id == size?.id }?.size

        self.init(variants: variants, selectedColour: colour, selectedSize: restored ?? Self.soleSize(in: options))
    }

    private init(variants: [Product.Variant], selectedColour: Product.Colour?, selectedSize: Product.ProductSize?) {
        self.variants = variants
        self.selectedColour = selectedColour
        self.selectedSize = selectedSize
    }

    public var colours: [ColourOption] {
        Self.distinctColours(in: variants).map { colour in
            ColourOption(colour: colour, isAvailable: Self.hasStock(colour, in: variants))
        }
    }

    public var sizes: [SizeOption] {
        Self.sizeOptions(in: variants, colour: selectedColour)
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
        let options = sizes

        // Stock is asked before size, so a colour with nothing left reads as out of stock rather
        // than asking for a size among chips that are all disabled.
        guard options.contains(where: \.isInStock) || options.isEmpty else {
            return .outOfStock
        }

        guard selectedSize != nil || options.isEmpty else {
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

        // Keep the size only where the new colour stocks it; never snap to a nearest size.
        let options = Self.sizeOptions(in: variants, colour: colour)
        let kept = options.first { $0.size.id == selectedSize?.id && $0.isInStock }?.size
        return Self(
            variants: variants,
            selectedColour: colour,
            selectedSize: kept ?? Self.soleSize(in: options)
        )
    }

    public func selecting(sizeID: String) -> Self {
        guard let size = sizes.first(where: { $0.size.id == sizeID })?.size else {
            return self
        }
        return Self(variants: variants, selectedColour: selectedColour, selectedSize: size)
    }

    // MARK: - Private

    private var variantsForSelectedColour: [Product.Variant] {
        Self.variants(in: variants, colour: selectedColour)
    }

    private static func variants(in variants: [Product.Variant], colour: Product.Colour?) -> [Product.Variant] {
        variants.filter { $0.colour?.id == colour?.id }
    }

    private static func sizeOptions(in variants: [Product.Variant], colour: Product.Colour?) -> [SizeOption] {
        let scoped = Self.variants(in: variants, colour: colour)
        return distinct(scoped.map(\.size), by: \.id).map { size in
            SizeOption(
                size: size,
                isInStock: scoped.contains { $0.size?.id == size.id && $0.stock > 0 }
            )
        }
    }

    private static func colour(_ id: String?, in variants: [Product.Variant]) -> Product.Colour? {
        Self.distinctColours(in: variants).first { $0.id == id }
    }

    private static func hasStock(_ colour: Product.Colour, in variants: [Product.Variant]) -> Bool {
        variants.contains { $0.colour?.id == colour.id && $0.stock > 0 }
    }

    /// The first colour that can actually be bought, falling back to the first colour when none can.
    private static func firstBuyableColour(in variants: [Product.Variant]) -> Product.Colour? {
        let colours = Self.distinctColours(in: variants)
        return colours.first { Self.hasStock($0, in: variants) } ?? colours.first
    }

    /// A lone size is implicit, so it is chosen for the shopper — out of stock included, so the CTA
    /// can say "out of stock" rather than asking for a size there is no choice about.
    private static func soleSize(in options: [SizeOption]) -> Product.ProductSize? {
        options.count == 1 ? options.first?.size : nil
    }

    /// Distinct colours in the order the BFF returned the variants, which is the merchandising
    /// order and not necessarily ascending by id.
    private static func distinctColours(in variants: [Product.Variant]) -> [Product.Colour] {
        distinct(variants.map(\.colour), by: \.id)
    }

    /// First occurrence wins, so the incoming order survives.
    private static func distinct<Element>(
        _ elements: [Element?],
        by id: (Element) -> String
    ) -> [Element] {
        var seen = Set<String>()
        return elements.compactMap { element in
            guard let element, seen.insert(id(element)).inserted else {
                return nil
            }
            return element
        }
    }
}
