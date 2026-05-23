@testable import Core
import Mocks
import Model
import TestUtils
import XCTest

final class UserDefaultsStoreTests: XCTestCase {
    private let key = "test.wishlist.key"

    // MARK: - save

    func test_save_writesEncodedDataUnderKey() throws {
        let (sut, mock) = makeSUT()
        var captured: [String: Data] = [:]
        mock.onSetCalled = { value, key in
            if let data = value as? Data { captured[key] = data }
        }
        let product = SelectedProduct(product: .fixture(id: "p-1"))

        sut.save([product])

        let written = try XCTUnwrap(captured[key])
        let decoded = try JSONDecoder().decode([PersistedProductDTO].self, from: written)
        XCTAssertEqual(decoded.map(\.productId), ["p-1"])
    }

    func test_save_overwritesPreviousValueForSameKey() throws {
        let (sut, mock) = makeSUT()
        var captured: [String: Data] = [:]
        mock.onSetCalled = { value, key in
            if let data = value as? Data { captured[key] = data }
        }

        sut.save([SelectedProduct(product: .fixture(id: "old"))])
        sut.save([SelectedProduct(product: .fixture(id: "new"))])

        let written = try XCTUnwrap(captured[key])
        let decoded = try JSONDecoder().decode([PersistedProductDTO].self, from: written)
        XCTAssertEqual(decoded.map(\.productId), ["new"])
    }

    func test_save_encodesEmptyArray_forEmptyInput() throws {
        let (sut, mock) = makeSUT()
        var captured: [String: Data] = [:]
        mock.onSetCalled = { value, key in
            if let data = value as? Data { captured[key] = data }
        }

        sut.save([])

        let written = try XCTUnwrap(captured[key])
        let decoded = try JSONDecoder().decode([PersistedProductDTO].self, from: written)
        XCTAssertTrue(decoded.isEmpty)
    }

    // MARK: - load

    func test_load_decodesProductsWrittenUnderKey() throws {
        let (sut, mock) = makeSUT()
        let product = SelectedProduct(product: .fixture(id: "p-1"))
        mock.forcedValueForKey[key] = try JSONEncoder().encode([PersistedProductDTO(from: product)])

        let loaded = sut.load()

        XCTAssertEqual(loaded.map(\.id), [product.id])
    }

    func test_load_returnsEmpty_whenNoDataStored() {
        let (sut, _) = makeSUT()

        XCTAssertTrue(sut.load().isEmpty)
    }

    func test_load_returnsEmpty_whenStoredDataIsCorrupted() {
        let (sut, mock) = makeSUT()
        mock.forcedValueForKey[key] = Data([0x00, 0x01, 0x02])

        XCTAssertTrue(sut.load().isEmpty)
    }

    // MARK: - round-trip

    func test_saveThenLoad_roundTripsDocumentedFields() throws {
        let (sut, mock) = makeSUT()
        var captured: [String: Data] = [:]
        mock.onSetCalled = { value, key in
            if let data = value as? Data { captured[key] = data }
        }
        let url = try XCTUnwrap(URL(string: "https://example.com/a.jpg"))
        let colour = Product.Colour.fixture(name: "Blue", media: [.image(.fixture(url: url))])
        let size = Product.ProductSize.fixture(value: "M", scale: "US")
        let price = Price.fixture(
            amount: .fixture(currencyCode: "AUD", amount: 5000, amountFormatted: "$50.00"),
            was: nil
        )
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

        sut.save([original])
        // Bridge the just-captured write over to the load-path lookup.
        mock.forcedValueForKey[key] = captured[key]

        let roundTripped = try XCTUnwrap(sut.load().first)

        XCTAssertEqual(roundTripped.product.id, original.product.id)
        XCTAssertEqual(roundTripped.brand.name, original.brand.name)
        XCTAssertEqual(roundTripped.name, original.name)
        XCTAssertEqual(roundTripped.selectedVariant.sku, original.selectedVariant.sku)
        XCTAssertEqual(roundTripped.stock, original.stock)
        XCTAssertEqual(roundTripped.media.first?.asImage?.url, original.media.first?.asImage?.url)
        XCTAssertEqual(roundTripped.colour?.name, original.colour?.name)
        XCTAssertEqual(roundTripped.sizeText, original.sizeText)
        // Full price fidelity (currency code + numeric amount + formatted) round-trips.
        XCTAssertEqual(roundTripped.selectedVariant.price.amount.currencyCode, "AUD")
        XCTAssertEqual(roundTripped.selectedVariant.price.amount.amount, 5000)
        XCTAssertEqual(roundTripped.selectedVariant.price.amount.amountFormatted, "$50.00")
        XCTAssertNil(roundTripped.selectedVariant.price.was)
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: UserDefaultsStore, mock: MockUserDefaults) {
        let mock = MockUserDefaults()
        let sut = UserDefaultsStore(userDefaults: mock, storageKey: key)
        trackForMemoryLeak(mock, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, mock)
    }
}
