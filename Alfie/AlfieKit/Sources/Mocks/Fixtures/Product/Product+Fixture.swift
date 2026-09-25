import Foundation
import Model

extension Product {
    public static func fixture(id: String = UUID().uuidString,
                               styleNumber: String = "0273393",
                               name: String = "Nolita SW Signature Loafer",
                               brand: Brand = .fixture(),
                               shortDescription: String = "",
                               longDescription: String? = nil,
                               slug: String = "",
                               priceRange: PriceRange? = nil,
                               attributes: AttributeCollection? = nil,
                               defaultVariant: Variant = .fixture(),
                               variants: [Variant] = [.fixture()],
                               colours: [Colour]? = nil) -> Product {
        .init(id: id,
              styleNumber: styleNumber,
              name: name,
              brand: brand,
              shortDescription: shortDescription,
              longDescription: longDescription,
              slug: slug,
              priceRange: priceRange,
              attributes: attributes,
              defaultVariant: defaultVariant,
              variants: variants,
              colours: colours)
    }
}

extension Product.Variant {
    /// `size` defaults to a real, *stable* size rather than nil: a sizeless variant cannot reach
    /// the colour x size derivation at all, which is how four green colour tests used to pass
    /// without ever crossing the seam they were written for. Stable so that two default variants
    /// read as one size, not two invented ones — pass an explicit size to vary the axis.
    public static func fixture(id: String? = nil,
                               sku: String = UUID().uuidString,
                               size: Product.ProductSize? = .fixture(id: "fixture-size", value: "M"),
                               colour: Product.Colour? = nil,
                               attributes: AttributeCollection? = nil,
                               stock: Int = 1,
                               price: Price = .fixture()) -> Product.Variant {
        .init(id: id,
              sku: sku,
              size: size,
              colour: colour,
              attributes: attributes,
              stock: stock,
              price: price)
    }
}

extension Product.Colour {
    public static func fixture(id: String = UUID().uuidString,
                               swatch: MediaImage? = nil,
                               name: String = "Black",
                               media: [Media] = []) -> Product.Colour {
        .init(id: id,
              swatch: swatch,
              name: name,
              media: media)
    }
}

extension Product.ProductSize {
    public static func fixture(id: String = UUID().uuidString,
                               value: String = "",
                               scale: String? = nil,
                               description: String? = nil,
                               sizeGuide: Product.SizeGuide? = nil) -> Product.ProductSize {
        .init(id: id,
              value: value,
              scale: scale,
              description: description,
              sizeGuide: sizeGuide)
    }
}

extension Product.SizeGuide {
    public static func fixture(id: String = UUID().uuidString,
                               name: String = "",
                               description: String? = nil,
                               sizes: [Product.ProductSize] = [.fixture()]) -> Product.SizeGuide {
        .init(id: id,
              name: name,
              description: description,
              sizes: sizes)
    }
}
