import XCTest
import ApolloTestSupport
@testable import BFFGraph
@testable import Core

final class ProductDetailsConverterTests: XCTestCase {
    // MARK: - Colour / size mapping

    func test_maps_colour_and_size_from_option_values() throws {
        let product = makeFragment(
            variants: [makeVariant(id: "v1", options: [("Color", "Red"), ("Size", "M")])]
        ).convertToProduct()

        let variant = try XCTUnwrap(product.variants.first)
        XCTAssertEqual(variant.colour?.name, "Red")
        XCTAssertEqual(variant.colour?.id, "Red")
        XCTAssertEqual(variant.size?.value, "M")
    }

    func test_colour_option_name_is_case_insensitive() throws {
        for name in ["color", "Color", "COLOUR", "colour"] {
            let product = makeFragment(
                variants: [makeVariant(id: "v1", options: [(name, "Blue")])]
            ).convertToProduct()

            XCTAssertEqual(
                product.variants.first?.colour?.name, "Blue",
                "Option name \"\(name)\" should map to a colour"
            )
        }
    }

    func test_unknown_option_names_yield_no_colour_or_size() throws {
        let product = makeFragment(
            variants: [makeVariant(id: "v1", options: [("material", "cotton")])]
        ).convertToProduct()

        let variant = try XCTUnwrap(product.variants.first)
        XCTAssertNil(variant.colour)
        XCTAssertNil(variant.size)
    }

    func test_colour_swatch_sources_from_variant_media() throws {
        let product = makeFragment(
            variants: [
                makeVariant(
                    id: "v1",
                    options: [("color", "Red")],
                    media: [Mock<Image>(altText: "Red shot", url: "https://cdn.alfie.test/red.jpg")]
                )
            ]
        ).convertToProduct()

        let swatch = try XCTUnwrap(product.variants.first?.colour?.swatch)
        XCTAssertEqual(swatch.url.absoluteString, "https://cdn.alfie.test/red.jpg")
    }

    // MARK: - Default variant

    func test_default_variant_matches_default_variant_id() {
        let product = makeFragment(
            defaultVariantId: "v2",
            variants: [
                makeVariant(id: "v1", options: [("size", "S")], available: 5),
                makeVariant(id: "v2", options: [("size", "M")], available: 5)
            ]
        ).convertToProduct()

        // defaultVariantId wins regardless of position/stock.
        XCTAssertEqual(product.defaultVariant.sku, "sku-v2")
    }

    func test_default_variant_falls_back_to_first_in_stock() {
        let product = makeFragment(
            defaultVariantId: nil,
            variants: [
                makeVariant(id: "v1", options: [("size", "S")], available: 0),
                makeVariant(id: "v2", options: [("size", "M")], available: 5)
            ]
        ).convertToProduct()

        XCTAssertEqual(product.defaultVariant.sku, "sku-v2")
    }

    func test_default_variant_falls_back_to_first_when_all_out_of_stock() {
        let product = makeFragment(
            defaultVariantId: nil,
            variants: [
                makeVariant(id: "v1", options: [("size", "S")], available: 0),
                makeVariant(id: "v2", options: [("size", "M")], available: 0)
            ]
        ).convertToProduct()

        XCTAssertEqual(product.defaultVariant.sku, "sku-v1")
    }

    // MARK: - Stock

    func test_stock_maps_from_inventory_available() {
        let product = makeFragment(
            variants: [makeVariant(id: "v1", options: [("size", "S")], available: 7)]
        ).convertToProduct()

        XCTAssertEqual(product.variants.first?.stock, 7)
    }

    func test_missing_inventory_yields_zero_stock() {
        let product = makeFragment(
            variants: [makeVariant(id: "v1", options: [("size", "S")], available: nil)]
        ).convertToProduct()

        XCTAssertEqual(product.variants.first?.stock, 0)
    }

    // MARK: - Scalar fields

    func test_maps_brand_name_and_strips_html_description() {
        let product = makeFragment(
            brandName: "Acme",
            descriptionHtml: "<p>Hello <b>World</b></p>",
            variants: [makeVariant(id: "v1")]
        ).convertToProduct()

        XCTAssertEqual(product.brand.name, "Acme")
        XCTAssertEqual(product.longDescription, "Hello World")
    }

    func test_strips_html_and_decodes_entities_without_double_decoding() {
        let product = makeFragment(
            descriptionHtml: "Tom &amp; Jerry &lt;3 &amp;lt; tag",
            variants: [makeVariant(id: "v1")]
        ).convertToProduct()

        // &amp; decodes last, so "&amp;lt;" stays "&lt;" rather than collapsing to "<".
        XCTAssertEqual(product.longDescription, "Tom & Jerry <3 &lt; tag")
    }

    func test_missing_brand_name_falls_back_to_empty_string() {
        let product = makeFragment(brandName: nil, variants: [makeVariant(id: "v1")])
            .convertToProduct()

        XCTAssertEqual(product.brand.name, "")
    }

    // MARK: - No-variant fallback

    func test_empty_variants_synthesises_default_variant() {
        let product = makeFragment(inventoryTotal: 9, variants: []).convertToProduct()

        XCTAssertTrue(product.variants.isEmpty)
        XCTAssertEqual(product.defaultVariant.sku, "")
        XCTAssertEqual(product.defaultVariant.stock, 9)
    }

    // MARK: - Colour aggregation

    func test_aggregates_distinct_colours_preserving_order() throws {
        let product = makeFragment(
            variants: [
                makeVariant(id: "v1", options: [("color", "Red"), ("size", "S")]),
                makeVariant(id: "v2", options: [("color", "Red"), ("size", "M")]),
                makeVariant(id: "v3", options: [("color", "Blue"), ("size", "S")])
            ]
        ).convertToProduct()

        let colours = try XCTUnwrap(product.colours)
        XCTAssertEqual(colours.map(\.name), ["Red", "Blue"])
    }
}

// MARK: - Test factory

private extension ProductDetailsConverterTests {
    func makeFragment(
        brandName: String? = "Acme",
        descriptionHtml: String? = nil,
        defaultVariantId: String? = nil,
        inventoryTotal: Int? = nil,
        amount: Double = 5.00,
        highAmount: Double? = nil,
        currencyCode: String = "GBP",
        primaryImage: Mock<Image>? = nil,
        variants: [Mock<ProductVariant>] = []
    ) -> BFFGraphAPI.ProductDetailsFragment {
        let low = Mock<Money>(amount: amount, currencyCode: currencyCode)
        let high = highAmount.map { Mock<Money>(amount: $0, currencyCode: currencyCode) } ?? low
        let priceRange = Mock<MoneyRange>(maxVariantPrice: high, minVariantPrice: low)

        let product = Mock<OmniProduct>()
        product.brandName = brandName
        product.descriptionHtml = descriptionHtml
        product.defaultVariantId = defaultVariantId
        product.id = "prod-1"
        product.inventoryTotal = inventoryTotal
        product.name = "Product"
        product.priceRange = priceRange
        product.primaryImage = primaryImage
        product.slug = "product"
        product.variants = variants

        return BFFGraphAPI.ProductDetailsFragment.from(product)
    }

    func makeVariant(
        id: String,
        options: [(String, String)] = [],
        available: Int? = nil,
        amount: Double = 5.00,
        currencyCode: String = "GBP",
        media: [Mock<Image>] = []
    ) -> Mock<ProductVariant> {
        let variant = Mock<ProductVariant>()
        variant.id = id
        variant.sku = "sku-\(id)"
        variant.price = Mock<Money>(amount: amount, currencyCode: currencyCode)
        variant.optionValues = options.map { Mock<VariantOption>(name: $0.0, value: $0.1) }
        if let available {
            variant.inventory = Mock<Inventory>(available: available)
        }
        variant.media = media
        return variant
    }
}
