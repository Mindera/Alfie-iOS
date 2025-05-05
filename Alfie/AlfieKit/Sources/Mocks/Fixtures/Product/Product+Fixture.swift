import Foundation
import Model

extension Product {
    public static func fixture(id: String = UUID().uuidString,
                               styleNumber: String = String(UUID().uuidString.prefix(8)),
                               name: String = "",
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
    public static func fixture(sku: String = UUID().uuidString,
                               size: Product.ProductSize? = nil,
                               colour: Product.Colour? = nil,
                               attributes: AttributeCollection? = nil,
                               stock: Int = 1,
                               price: Price = .fixture()) -> Product.Variant {
        .init(sku: sku,
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
                               name: String = "",
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
