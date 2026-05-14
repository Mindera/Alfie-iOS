@testable import Core
import Mocks
import Model
import XCTest

final class PersistedProductDTOTests: XCTestCase {

    // MARK: - Domain → DTO

    func test_initFromSelectedProduct_mapsProductIdAndVariantSku() {
        let variant = Product.Variant.fixture(sku: "sku-abc")
        let product = Product.fixture(id: "prod-1", defaultVariant: variant, variants: [variant])

        let dto = PersistedProductDTO(from: SelectedProduct(product: product, selectedVariant: variant))

        XCTAssertEqual(dto.productId, "prod-1")
        XCTAssertEqual(dto.variantSku, "sku-abc")
    }

    func test_initFromSelectedProduct_mapsNameAndBrand() {
        let product = Product.fixture(name: "Cashmere Coat", brand: .fixture(name: "Acme"))

        let dto = PersistedProductDTO(from: SelectedProduct(product: product))

        XCTAssertEqual(dto.name, "Cashmere Coat")
        XCTAssertEqual(dto.brandName, "Acme")
    }

    func test_initFromSelectedProduct_mapsStock() {
        let variant = Product.Variant.fixture(stock: 7)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])

        let dto = PersistedProductDTO(from: SelectedProduct(product: product, selectedVariant: variant))

        XCTAssertEqual(dto.stock, 7)
    }

    func test_initFromSelectedProduct_sizeTextIsNil_whenVariantHasNoSize() {
        let variant = Product.Variant.fixture(size: nil)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])

        let dto = PersistedProductDTO(from: SelectedProduct(product: product, selectedVariant: variant))

        XCTAssertNil(dto.sizeText)
    }

    func test_initFromSelectedProduct_sizeText_combinesValueAndScale_whenBothPresent() {
        let size = Product.ProductSize.fixture(value: "M", scale: "US")
        let variant = Product.Variant.fixture(size: size)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])

        let dto = PersistedProductDTO(from: SelectedProduct(product: product, selectedVariant: variant))

        XCTAssertEqual(dto.sizeText, "M US")
    }

    func test_initFromSelectedProduct_sizeText_isValueOnly_whenScaleIsNil() {
        let size = Product.ProductSize.fixture(value: "M", scale: nil)
        let variant = Product.Variant.fixture(size: size)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])

        let dto = PersistedProductDTO(from: SelectedProduct(product: product, selectedVariant: variant))

        XCTAssertEqual(dto.sizeText, "M")
    }

    func test_initFromSelectedProduct_mapsColourName() {
        let colour = Product.Colour.fixture(name: "Blue")
        let variant = Product.Variant.fixture(colour: colour)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])

        let dto = PersistedProductDTO(from: SelectedProduct(product: product, selectedVariant: variant))

        XCTAssertEqual(dto.colourName, "Blue")
    }

    func test_initFromSelectedProduct_capturesFirstImageURL_fromColourMedia() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/a.jpg"))
        let image = MediaImage.fixture(url: url)
        let colour = Product.Colour.fixture(name: "Blue", media: [.image(image)])
        let variant = Product.Variant.fixture(colour: colour)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])

        let dto = PersistedProductDTO(from: SelectedProduct(product: product, selectedVariant: variant))

        XCTAssertEqual(dto.imageURL, url)
    }

    func test_initFromSelectedProduct_colourAndImageNil_whenVariantHasNeither() {
        let variant = Product.Variant.fixture(colour: nil)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])

        let dto = PersistedProductDTO(from: SelectedProduct(product: product, selectedVariant: variant))

        XCTAssertNil(dto.colourName)
        XCTAssertNil(dto.imageURL)
    }

    // MARK: - DTO → Domain (`selectedProduct`)

    func test_selectedProduct_exposesIdentifiers() {
        let dto = PersistedProductDTO.testFixture(productId: "p", variantSku: "v")

        let selected = dto.selectedProduct

        XCTAssertEqual(selected.product.id, "p")
        XCTAssertEqual(selected.selectedVariant.sku, "v")
        XCTAssertEqual(selected.id, "p-v")
    }

    func test_selectedProduct_exposesNameAndBrand() {
        let dto = PersistedProductDTO.testFixture(name: "Tee", brandName: "Acme")

        let selected = dto.selectedProduct

        XCTAssertEqual(selected.name, "Tee")
        XCTAssertEqual(selected.brand.name, "Acme")
    }

    func test_selectedProduct_exposesStock() {
        let dto = PersistedProductDTO.testFixture(stock: 5)

        XCTAssertEqual(dto.selectedProduct.stock, 5)
    }

    func test_selectedProduct_exposesImageURL() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/a.jpg"))
        let dto = PersistedProductDTO.testFixture(imageURL: url)

        XCTAssertEqual(dto.selectedProduct.media.first?.asImage?.url, url)
    }

    func test_selectedProduct_exposesColourName() {
        let dto = PersistedProductDTO.testFixture(colourName: "Blue")

        XCTAssertEqual(dto.selectedProduct.colour?.name, "Blue")
    }

    func test_selectedProduct_exposesSizeText_viaSizeValueField() {
        let dto = PersistedProductDTO.testFixture(sizeText: "M US")

        XCTAssertEqual(dto.selectedProduct.sizeText, "M US")
        XCTAssertEqual(dto.selectedProduct.size?.value, "M US")
    }

    func test_selectedProduct_sizeIsNil_whenSizeTextIsNil() {
        let dto = PersistedProductDTO.testFixture(sizeText: nil)

        XCTAssertNil(dto.selectedProduct.size)
    }

    func test_selectedProduct_colourIsNil_whenColourNameAndImageURLAreNil() {
        let dto = PersistedProductDTO.testFixture(imageURL: nil, colourName: nil)

        XCTAssertNil(dto.selectedProduct.colour)
    }

    // MARK: - Codable

    func test_dto_codableRoundTrip() throws {
        let original = PersistedProductDTO(
            productId: "p-1",
            variantSku: "v-1",
            name: "Tee",
            brandName: "Acme",
            imageURL: URL(string: "https://example.com/a.jpg"),
            colourName: "Blue",
            sizeText: "M US",
            priceType: .sale(fullPrice: "$100", finalPrice: "$80"),
            stock: 3
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PersistedProductDTO.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    // MARK: - SelectedProduct → DTO → SelectedProduct (full documented field set)

    func test_selectedProductRoundTrip_preservesDocumentedFields() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/a.jpg"))
        let colour = Product.Colour.fixture(name: "Blue", media: [.image(.fixture(url: url))])
        let size = Product.ProductSize.fixture(value: "M", scale: "US")
        let price = Price.fixture(amount: .fixture(amountFormatted: "$50"))
        let variant = Product.Variant.fixture(
            sku: "sku-1",
            size: size,
            colour: colour,
            stock: 3,
            price: price
        )
        let product = Product.fixture(
            id: "p-1",
            name: "Tee",
            brand: .fixture(name: "Acme"),
            defaultVariant: variant,
            variants: [variant]
        )
        let original = SelectedProduct(product: product, selectedVariant: variant)

        let roundTripped = PersistedProductDTO(from: original).selectedProduct

        XCTAssertEqual(roundTripped.product.id, original.product.id)
        XCTAssertEqual(roundTripped.brand.name, original.brand.name)
        XCTAssertEqual(roundTripped.name, original.name)
        XCTAssertEqual(roundTripped.selectedVariant.sku, original.selectedVariant.sku)
        XCTAssertEqual(roundTripped.stock, original.stock)
        XCTAssertEqual(roundTripped.media.first?.asImage?.url, original.media.first?.asImage?.url)
        XCTAssertEqual(roundTripped.colour?.name, original.colour?.name)
        XCTAssertEqual(roundTripped.sizeText, original.sizeText)
        XCTAssertEqual(
            PersistedPriceTypeDTO(from: roundTripped.priceType),
            PersistedPriceTypeDTO(from: original.priceType)
        )
    }
}

// MARK: - PersistedPriceTypeDTO

final class PersistedPriceTypeDTOTests: XCTestCase {

    // MARK: - init(from:)

    func test_initFrom_mapsDefaultCase() {
        let dto = PersistedPriceTypeDTO(from: .default(price: "$10"))

        XCTAssertEqual(dto, .default(price: "$10"))
    }

    func test_initFrom_mapsSaleCase() {
        let dto = PersistedPriceTypeDTO(from: .sale(fullPrice: "$20", finalPrice: "$15"))

        XCTAssertEqual(dto, .sale(fullPrice: "$20", finalPrice: "$15"))
    }

    func test_initFrom_mapsRangeCase() {
        let dto = PersistedPriceTypeDTO(from: .range(lowerBound: "$5", upperBound: "$25", separator: "-"))

        XCTAssertEqual(dto, .range(lowerBound: "$5", upperBound: "$25", separator: "-"))
    }

    // MARK: - synthesizedPrice round-trip

    func test_synthesizedPrice_defaultRoundTripsViaSelectedProduct() {
        let original = PersistedPriceTypeDTO.default(price: "$50")
        let variant = Product.Variant.fixture(price: original.synthesizedPrice)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        let selected = SelectedProduct(product: product, selectedVariant: variant)

        XCTAssertEqual(PersistedPriceTypeDTO(from: selected.priceType), original)
    }

    func test_synthesizedPrice_saleRoundTripsViaSelectedProduct() {
        let original = PersistedPriceTypeDTO.sale(fullPrice: "$100", finalPrice: "$80")
        let variant = Product.Variant.fixture(price: original.synthesizedPrice)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        let selected = SelectedProduct(product: product, selectedVariant: variant)

        XCTAssertEqual(PersistedPriceTypeDTO(from: selected.priceType), original)
    }

    // MARK: - Codable

    func test_dto_codableRoundTrip_defaultCase() throws {
        let original = PersistedPriceTypeDTO.default(price: "$10")

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PersistedPriceTypeDTO.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    func test_dto_codableRoundTrip_saleCase() throws {
        let original = PersistedPriceTypeDTO.sale(fullPrice: "$20", finalPrice: "$15")

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PersistedPriceTypeDTO.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    func test_dto_codableRoundTrip_rangeCase() throws {
        let original = PersistedPriceTypeDTO.range(lowerBound: "$5", upperBound: "$25", separator: "-")

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PersistedPriceTypeDTO.self, from: data)

        XCTAssertEqual(decoded, original)
    }
}

// MARK: - Test helpers

private extension PersistedProductDTO {
    /// Convenience builder for DTO-side tests where we want to exercise the reverse
    /// mapping (`selectedProduct`) without constructing a full domain `SelectedProduct`.
    static func testFixture(
        productId: String = "p",
        variantSku: String = "v",
        name: String = "",
        brandName: String = "",
        imageURL: URL? = nil,
        colourName: String? = nil,
        sizeText: String? = nil,
        priceType: PersistedPriceTypeDTO = .default(price: ""),
        stock: Int = 0
    ) -> PersistedProductDTO {
        .init(
            productId: productId,
            variantSku: variantSku,
            name: name,
            brandName: brandName,
            imageURL: imageURL,
            colourName: colourName,
            sizeText: sizeText,
            priceType: priceType,
            stock: stock
        )
    }
}
