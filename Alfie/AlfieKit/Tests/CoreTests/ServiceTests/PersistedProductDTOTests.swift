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

    func test_initFromSelectedProduct_mapsSlug() {
        let product = Product.fixture(slug: "cashmere-coat-26146503")

        let dto = PersistedProductDTO(from: SelectedProduct(product: product))

        XCTAssertEqual(dto.slug, "cashmere-coat-26146503")
    }

    func test_restoredSelectedProduct_preservesSlug_soPdpCanRefetch() {
        // Bag/Wishlist → PDP re-fetches via `productDetails(handle:)`; the slug must survive the
        // round-trip, otherwise the handle is empty and the PDP shows "not found".
        let product = Product.fixture(slug: "cashmere-coat-26146503")
        let dto = PersistedProductDTO(from: SelectedProduct(product: product))

        XCTAssertEqual(dto.selectedProduct.product.slug, "cashmere-coat-26146503")
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

    func test_initFromSelectedProduct_capturesFullPrice_whenNotOnSale() {
        let money = Money.fixture(currencyCode: "AUD", amount: 5000, amountFormatted: "$50.00")
        let price = Price.fixture(amount: money, was: nil)
        let variant = Product.Variant.fixture(price: price)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])

        let dto = PersistedProductDTO(from: SelectedProduct(product: product, selectedVariant: variant))

        XCTAssertEqual(dto.price.amount.currencyCode, "AUD")
        XCTAssertEqual(dto.price.amount.amount, 5000)
        XCTAssertEqual(dto.price.amount.amountFormatted, "$50.00")
        XCTAssertNil(dto.price.was)
    }

    func test_initFromSelectedProduct_capturesPreviousPrice_whenOnSale() {
        let current = Money.fixture(currencyCode: "AUD", amount: 8000, amountFormatted: "$80.00")
        let was = Money.fixture(currencyCode: "AUD", amount: 10_000, amountFormatted: "$100.00")
        let price = Price.fixture(amount: current, was: was)
        let variant = Product.Variant.fixture(price: price)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])

        let dto = PersistedProductDTO(from: SelectedProduct(product: product, selectedVariant: variant))

        XCTAssertEqual(dto.price.amount.amount, 8000)
        XCTAssertEqual(dto.price.was?.amount, 10_000)
        XCTAssertEqual(dto.price.was?.amountFormatted, "$100.00")
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

    func test_selectedProduct_restoresFullPriceFidelity() {
        let dto = PersistedProductDTO.testFixture(
            price: PersistedPriceDTO(
                amount: PersistedMoneyDTO(currencyCode: "AUD", amount: 5000, amountFormatted: "$50.00"),
                was: PersistedMoneyDTO(currencyCode: "AUD", amount: 6500, amountFormatted: "$65.00")
            )
        )

        let restored = dto.selectedProduct.selectedVariant.price

        XCTAssertEqual(restored.amount.currencyCode, "AUD")
        XCTAssertEqual(restored.amount.amount, 5000)
        XCTAssertEqual(restored.amount.amountFormatted, "$50.00")
        XCTAssertEqual(restored.was?.amount, 6500)
        XCTAssertEqual(restored.was?.amountFormatted, "$65.00")
    }

    func test_selectedProduct_priceType_isSale_whenPersistedPriceHasWas() {
        let dto = PersistedProductDTO.testFixture(
            price: PersistedPriceDTO(
                amount: PersistedMoneyDTO(currencyCode: "AUD", amount: 8000, amountFormatted: "$80.00"),
                was: PersistedMoneyDTO(currencyCode: "AUD", amount: 10_000, amountFormatted: "$100.00")
            )
        )

        guard case let .sale(fullPrice, finalPrice) = dto.selectedProduct.priceType else {
            return XCTFail("Expected sale priceType, got \(dto.selectedProduct.priceType)")
        }
        XCTAssertEqual(fullPrice, "$100.00")
        XCTAssertEqual(finalPrice, "$80.00")
    }

    func test_selectedProduct_priceType_isDefault_whenPersistedPriceHasNoWas() {
        let dto = PersistedProductDTO.testFixture(
            price: PersistedPriceDTO(
                amount: PersistedMoneyDTO(currencyCode: "AUD", amount: 5000, amountFormatted: "$50.00"),
                was: nil
            )
        )

        guard case let .default(price) = dto.selectedProduct.priceType else {
            return XCTFail("Expected default priceType, got \(dto.selectedProduct.priceType)")
        }
        XCTAssertEqual(price, "$50.00")
    }

    // MARK: - Codable

    func test_dto_codableRoundTrip() throws {
        let original = PersistedProductDTO(
            productId: "p-1",
            slug: "tee-12345678",
            variantSku: "v-1",
            name: "Tee",
            brandName: "Acme",
            imageURL: URL(string: "https://example.com/a.jpg"),
            colourName: "Blue",
            sizeText: "M US",
            price: PersistedPriceDTO(
                amount: PersistedMoneyDTO(currencyCode: "AUD", amount: 8000, amountFormatted: "$80.00"),
                was: PersistedMoneyDTO(currencyCode: "AUD", amount: 10_000, amountFormatted: "$100.00")
            ),
            stock: 3
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PersistedProductDTO.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    // MARK: - SelectedProduct → DTO → SelectedProduct (full round-trip)

    func test_selectedProductRoundTrip_preservesAllCapturedFields() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/a.jpg"))
        let colour = Product.Colour.fixture(name: "Blue", media: [.image(.fixture(url: url))])
        let size = Product.ProductSize.fixture(value: "M", scale: "US")
        let money = Money.fixture(currencyCode: "AUD", amount: 5000, amountFormatted: "$50.00")
        let price = Price.fixture(amount: money, was: nil)
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
        // Full Price fidelity round-trips, including numeric amount and currency.
        XCTAssertEqual(roundTripped.selectedVariant.price.amount.currencyCode, "AUD")
        XCTAssertEqual(roundTripped.selectedVariant.price.amount.amount, 5000)
        XCTAssertEqual(roundTripped.selectedVariant.price.amount.amountFormatted, "$50.00")
        XCTAssertNil(roundTripped.selectedVariant.price.was)
    }
}

// MARK: - PersistedPriceDTO / PersistedMoneyDTO

final class PersistedPriceDTOTests: XCTestCase {

    // MARK: - init(from:)

    func test_initFromPrice_capturesAmount_andNilWas_whenNotOnSale() {
        let price = Price.fixture(
            amount: .fixture(currencyCode: "AUD", amount: 5000, amountFormatted: "$50.00"),
            was: nil
        )

        let dto = PersistedPriceDTO(from: price)

        XCTAssertEqual(dto.amount.currencyCode, "AUD")
        XCTAssertEqual(dto.amount.amount, 5000)
        XCTAssertEqual(dto.amount.amountFormatted, "$50.00")
        XCTAssertNil(dto.was)
    }

    func test_initFromPrice_capturesAmountAndWas_whenOnSale() {
        let price = Price.fixture(
            amount: .fixture(currencyCode: "AUD", amount: 8000, amountFormatted: "$80.00"),
            was: .fixture(currencyCode: "AUD", amount: 10_000, amountFormatted: "$100.00")
        )

        let dto = PersistedPriceDTO(from: price)

        XCTAssertEqual(dto.amount.amount, 8000)
        XCTAssertEqual(dto.was?.amount, 10_000)
        XCTAssertEqual(dto.was?.amountFormatted, "$100.00")
    }

    // MARK: - domain (DTO → Price)

    func test_domain_reconstructsPriceFaithfully() {
        let dto = PersistedPriceDTO(
            amount: PersistedMoneyDTO(currencyCode: "AUD", amount: 5000, amountFormatted: "$50.00"),
            was: PersistedMoneyDTO(currencyCode: "AUD", amount: 6500, amountFormatted: "$65.00")
        )

        let price = dto.domain

        XCTAssertEqual(price.amount.currencyCode, "AUD")
        XCTAssertEqual(price.amount.amount, 5000)
        XCTAssertEqual(price.amount.amountFormatted, "$50.00")
        XCTAssertEqual(price.was?.amount, 6500)
        XCTAssertEqual(price.was?.amountFormatted, "$65.00")
    }

    // MARK: - Codable

    func test_dto_codableRoundTrip_default() throws {
        let original = PersistedPriceDTO(
            amount: PersistedMoneyDTO(currencyCode: "AUD", amount: 5000, amountFormatted: "$50.00"),
            was: nil
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PersistedPriceDTO.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    func test_dto_codableRoundTrip_sale() throws {
        let original = PersistedPriceDTO(
            amount: PersistedMoneyDTO(currencyCode: "AUD", amount: 8000, amountFormatted: "$80.00"),
            was: PersistedMoneyDTO(currencyCode: "AUD", amount: 10_000, amountFormatted: "$100.00")
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PersistedPriceDTO.self, from: data)

        XCTAssertEqual(decoded, original)
    }
}

// MARK: - Test helpers

private extension PersistedProductDTO {
    /// Convenience builder for DTO-side tests where we want to exercise the reverse
    /// mapping (`selectedProduct`) without constructing a full domain `SelectedProduct`.
    static func testFixture(
        productId: String = "p",
        slug: String = "",
        variantSku: String = "v",
        name: String = "",
        brandName: String = "",
        imageURL: URL? = nil,
        colourName: String? = nil,
        sizeText: String? = nil,
        price: PersistedPriceDTO = .testDefault,
        stock: Int = 0
    ) -> PersistedProductDTO {
        .init(
            productId: productId,
            slug: slug,
            variantSku: variantSku,
            name: name,
            brandName: brandName,
            imageURL: imageURL,
            colourName: colourName,
            sizeText: sizeText,
            price: price,
            stock: stock
        )
    }
}

private extension PersistedPriceDTO {
    static let testDefault = PersistedPriceDTO(
        amount: PersistedMoneyDTO(currencyCode: "", amount: 0, amountFormatted: ""),
        was: nil
    )
}
