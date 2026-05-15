@testable import Core
import Mocks
import Model
import TestUtils
import XCTest

final class BagServiceTests: XCTestCase {

    // MARK: - init

    func test_init_loadsContentFromStore() {
        let stored = [
            SelectedProduct(product: .fixture(id: "p1")),
            SelectedProduct(product: .fixture(id: "p2"))
        ]
        let (sut, _) = makeSUT(initialContent: stored)

        XCTAssertEqual(sut.getBagContent().map(\.id), stored.map(\.id))
    }

    func test_init_withEmptyStore_returnsEmptyContent() {
        let (sut, _) = makeSUT()

        XCTAssertTrue(sut.getBagContent().isEmpty)
    }

    func test_init_doesNotPersistOnLoad() {
        let (_, store) = makeSUT(initialContent: [SelectedProduct(product: .fixture(id: "p1"))])

        XCTAssertTrue(store.saveInvocations.isEmpty)
    }

    // MARK: - addProduct

    func test_addProduct_appendsProductToBag() {
        let (sut, _) = makeSUT()
        let product = SelectedProduct(product: .fixture(id: "product-1"))

        sut.addProduct(product)

        XCTAssertEqual(sut.getBagContent().count, 1)
        XCTAssertEqual(sut.getBagContent().first?.product.id, "product-1")
    }

    func test_addProduct_persistsToStore() throws {
        let (sut, store) = makeSUT()
        let product = SelectedProduct(product: .fixture(id: "product-1"))

        sut.addProduct(product)

        XCTAssertEqual(store.saveInvocations.count, 1)
        let saved = try XCTUnwrap(store.saveInvocations.last)
        XCTAssertEqual(saved.map(\.id), [product.id])
    }

    func test_addProduct_doesNotDuplicateSameVariant() {
        let (sut, store) = makeSUT()
        let product = Product.fixture(id: "product-1")
        let selected = SelectedProduct(product: product)

        sut.addProduct(selected)
        sut.addProduct(selected)

        XCTAssertEqual(sut.getBagContent().count, 1)
        // Duplicate add short-circuits, so only one save invocation.
        XCTAssertEqual(store.saveInvocations.count, 1)
    }

    func test_addProduct_keepsDifferentVariantsOfSameProduct() {
        let (sut, _) = makeSUT()
        let blue = Product.Variant.fixture(sku: "sku-blue")
        let red = Product.Variant.fixture(sku: "sku-red")
        let product = Product.fixture(id: "p-1", defaultVariant: blue, variants: [blue, red])

        sut.addProduct(SelectedProduct(product: product, selectedVariant: blue))
        sut.addProduct(SelectedProduct(product: product, selectedVariant: red))

        XCTAssertEqual(sut.getBagContent().count, 2)
    }

    // MARK: - removeProduct

    func test_removeProduct_removesMatchingEntry() {
        let (sut, _) = makeSUT()
        let product = SelectedProduct(product: .fixture(id: "product-1"))
        sut.addProduct(product)

        sut.removeProduct(product)

        XCTAssertTrue(sut.getBagContent().isEmpty)
    }

    func test_removeProduct_persistsToStore() throws {
        let (sut, store) = makeSUT()
        let product = SelectedProduct(product: .fixture(id: "product-1"))
        sut.addProduct(product)

        sut.removeProduct(product)

        // 1 save on add + 1 on remove
        XCTAssertEqual(store.saveInvocations.count, 2)
        let lastSave = try XCTUnwrap(store.saveInvocations.last)
        XCTAssertTrue(lastSave.isEmpty)
    }

    func test_removeProduct_doesNotAffectOtherProducts() {
        let (sut, _) = makeSUT()
        let keep = SelectedProduct(product: .fixture(id: "keep"))
        let remove = SelectedProduct(product: .fixture(id: "remove"))
        sut.addProduct(keep)
        sut.addProduct(remove)

        sut.removeProduct(remove)

        let remaining = sut.getBagContent()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.product.id, "keep")
    }

    func test_removeProduct_isNoOp_whenProductNotInBag() {
        let (sut, _) = makeSUT()
        sut.addProduct(SelectedProduct(product: .fixture(id: "keep")))

        sut.removeProduct(SelectedProduct(product: .fixture(id: "missing")))

        XCTAssertEqual(sut.getBagContent().count, 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        initialContent: [SelectedProduct] = [],
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: BagService, store: MockBagStore) {
        let store = MockBagStore(initialContent: initialContent)
        let sut = BagService(store: store)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
}
