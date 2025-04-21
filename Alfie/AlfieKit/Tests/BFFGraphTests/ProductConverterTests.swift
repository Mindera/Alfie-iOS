import XCTest
import ApolloTestSupport
@testable import BFFGraph

final class ProductConverterTests: XCTestCase {
    func test_product_valid() {
        let brand: Mock<Brand> = .mock(id: "brandId",
                                       name: "Brand",
                                       slug: "brand")

        let priceRange: Mock<PriceRange> = .mock(low: .mock(currencyCode: "AUD",
                                                            amount: 1,
                                                            amountFormatted: "$1.00"),
                                                 high: .mock(currencyCode: "AUD",
                                                             amount: 100,
                                                             amountFormatted: "$100.00"))

        let size: Mock<Size> = .mock(id: "sizeId",
                                     value: "XL",
                                     scale: "INT",
                                     description: "size description")

        let color: Mock<Colour> = .mock(id: "colorId",
                                        swatch: .mock(),
                                        name: "single color",
                                        media: [.mock()])

        let price: Mock<Price> = .mock(amount: .mock(currencyCode: "AUD",
                                                     amount: 10,
                                                     amountFormatted: "$10.00"),
                                       was: .mock(currencyCode: "AUD",
                                                  amount: 20,
                                                  amountFormatted: "$20.00"))

        let variant: Mock<Variant> = .mock(sku: "sku",
                                           size: size,
                                           colour: color,
                                           attributes: [.mock(key: "key", value: "value")],
                                           stock: 100,
                                           price: price)

        let mockProduct: Mock<Product> = .mock(id: "id",
                                               styleNumber: "styleNumber",
                                               name: "product name",
                                               brand: brand,
                                               shortDescription: "short description",
                                               longDescription: "long description",
                                               slug: "slug",
                                               priceRange: priceRange,
                                               attributes: [.mock(key: "key", value: "value")],
                                               defaultVariant: variant,
                                               variants: [variant],
                                               colours: [color])

        let response = BFFGraphAPI.GetProductQuery.Data.Product.from(mockProduct)
        let product = response.convertToProduct()

        XCTAssertEqual(product.id, "id")
        XCTAssertEqual(product.styleNumber, "styleNumber")
        XCTAssertEqual(product.name, "product name")
        XCTAssertEqual(product.shortDescription, "short description")
        XCTAssertEqual(product.longDescription, "long description")
        XCTAssertEqual(product.slug, "slug")
        XCTAssertEqual(product.attributes, ["key": "value"])

        XCTAssertEqual(product.brand.id, "brandId")
        XCTAssertEqual(product.brand.name, "Brand")
        XCTAssertEqual(product.brand.slug, "brand")

        XCTAssertEqual(product.priceRange?.low.currencyCode, "AUD")
        XCTAssertEqual(product.priceRange?.low.amount, 1)
        XCTAssertEqual(product.priceRange?.low.amountFormatted, "$1.00")
        XCTAssertEqual(product.priceRange?.high?.currencyCode, "AUD")
        XCTAssertEqual(product.priceRange?.high?.amount, 100)
        XCTAssertEqual(product.priceRange?.high?.amountFormatted, "$100.00")

        XCTAssertEqual(product.defaultVariant.sku, "sku")
        XCTAssertEqual(product.defaultVariant.size?.id, "sizeId")
        XCTAssertEqual(product.defaultVariant.size?.value, "XL")
        XCTAssertEqual(product.defaultVariant.size?.scale, "INT")
        XCTAssertEqual(product.defaultVariant.size?.description, "size description")
        XCTAssertEqual(product.defaultVariant.size?.id, "sizeId")
        XCTAssertEqual(product.defaultVariant.colour?.id, "colorId")
        XCTAssertNotNil(product.defaultVariant.colour?.swatch)
        XCTAssertEqual(product.defaultVariant.colour?.name, "single color")
        XCTAssertEqual(product.defaultVariant.media.count, 1)
        XCTAssertEqual(product.defaultVariant.attributes, ["key": "value"])
        XCTAssertEqual(product.defaultVariant.stock, 100)
        XCTAssertEqual(product.defaultVariant.price.amount.currencyCode, "AUD")
        XCTAssertEqual(product.defaultVariant.price.amount.amount, 10)
        XCTAssertEqual(product.defaultVariant.price.amount.amountFormatted, "$10.00")
        XCTAssertEqual(product.defaultVariant.price.was?.currencyCode, "AUD")
        XCTAssertEqual(product.defaultVariant.price.was?.amount, 20)
        XCTAssertEqual(product.defaultVariant.price.was?.amountFormatted, "$20.00")

        XCTAssertEqual(product.variants.count, 1)
        XCTAssertEqual(product.colours?.count, 1)
    }
}
