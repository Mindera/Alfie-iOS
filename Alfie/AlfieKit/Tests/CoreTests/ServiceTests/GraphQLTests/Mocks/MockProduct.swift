import ApolloTestSupport
import BFFGraphAPI
import BFFGraphMocks

extension Mock<Product> {
    static func mock(id: String = "",
                     styleNumber: String = "",
                     name: String = "",
                     brand: Mock<Brand> = .mock(),
                     shortDescription: String = "",
                     longDescription: String? = nil,
                     slug: String = "",
                     priceRange: Mock<PriceRange>? = nil,
                     attributes: [Mock<KeyValuePair>]? = nil,
                     labels: [String]? = nil,
                     defaultVariant: Mock<Variant> = .mock(),
                     variants: [Mock<Variant>] = [.mock()],
                     colours: [Mock<Colour>]? = nil) -> Mock<Product> {
        Mock<Product>(attributes: attributes,
                      brand: brand,
                      colours: colours,
                      defaultVariant: defaultVariant,
                      id: id,
                      labels: labels,
                      longDescription: longDescription,
                      name: name,
                      priceRange: priceRange,
                      shortDescription: shortDescription,
                      slug: slug,
                      styleNumber: styleNumber,
                      variants: variants)
    }
}

extension Mock<PriceRange> {
    static func mock(low: Mock<Money> = .mock(),
                     high: Mock<Money>? = .mock()) -> Mock<PriceRange> {
        Mock<PriceRange>(high: high, low: low)
    }
}

extension Mock<Money> {
    static func mock(currencyCode: String = "AUD",
                     amount: Int = 1,
                     amountFormatted: String = "$1.00") -> Mock<Money> {
        Mock<Money>(amount: amount,
                    amountFormatted: amountFormatted,
                    currencyCode: currencyCode)
    }
}

extension Mock<Variant> {
    static func mock(sku: String = "",
                     size: Mock<Size>? = nil,
                     colour: Mock<Colour>? = nil,
                     attributes: [Mock<KeyValuePair>]? = nil,
                     stock: Int = 1,
                     price: Mock<Price> = .mock()) -> Mock<Variant> {
        Mock<Variant>(attributes: attributes,
                      colour: colour,
                      price: price,
                      size: size, 
                      sku: sku,
                      stock: stock)
    }
}

extension Mock<Price> {
    static func mock(amount: Mock<Money> = .mock(),
                     was: Mock<Money>? = nil) -> Mock<Price> {
        Mock<Price>(amount: amount, was: was)
    }
}

extension Mock<Colour> {
    static func mock(id: String = "",
                     swatch: Mock<Image>? = nil,
                     name: String = "",
                     media: [Mock<Image>] = []) -> Mock<Colour> {
        Mock<Colour>(id: id,
                     media: media,
                     name: name,
                     swatch: swatch)
    }
}

extension Mock<Size> {
    static func mock(id: String = "",
                     value: String = "",
                     scale: String? = nil,
                     description: String? = nil,
                     sizeGuide: Mock<SizeGuide>? = nil) -> Mock<Size> {
        Mock<Size>(description: description,
                   id: id,
                   scale: scale,
                   sizeGuide: sizeGuide,
                   value: value)
    }
}

extension Mock<SizeGuide> {
    static func mock(id: String = "",
                     name: String = "",
                     description: String? = nil,
                     sizes: [Mock<Size>] = [.mock()]) -> Mock<SizeGuide> {
        Mock<SizeGuide>(description: description,
                        id: id,
                        name: name,
                        sizes: sizes)
    }
}
