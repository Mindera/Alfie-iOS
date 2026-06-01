@testable import Core
import Mocks
import Model
import TestUtils
import XCTest

final class BagServiceTests: XCTestCase {

    // MARK: - init

    func test_init_loadsContentFromStore() async {
        let stored = [
            SelectedProduct(product: .fixture(id: "p1")),
            SelectedProduct(product: .fixture(id: "p2"))
        ]
        let (sut, _) = makeSUT(initialContent: stored)

        let content = await sut.getBagContent()
        XCTAssertEqual(content.map(\.id), stored.map(\.id))
    }

    func test_init_withEmptyStore_returnsEmptyContent() async {
        let (sut, _) = makeSUT()

        let content = await sut.getBagContent()
        XCTAssertTrue(content.isEmpty)
    }

    func test_init_doesNotPersistOnLoad() {
        let (_, store) = makeSUT(initialContent: [SelectedProduct(product: .fixture(id: "p1"))])

        XCTAssertTrue(store.saveInvocations.isEmpty)
    }

    // MARK: - addProduct

    func test_addProduct_appendsProductToBag() async {
        let (sut, _) = makeSUT()
        let product = SelectedProduct(product: .fixture(id: "product-1"))

        await sut.addProduct(product)

        let content = await sut.getBagContent()
        XCTAssertEqual(content.count, 1)
        XCTAssertEqual(content.first?.product.id, "product-1")
    }

    func test_addProduct_persistsToStore() async throws {
        let (sut, store) = makeSUT()
        let product = SelectedProduct(product: .fixture(id: "product-1"))

        await sut.addProduct(product)

        XCTAssertEqual(store.saveInvocations.count, 1)
        let saved = try XCTUnwrap(store.saveInvocations.last)
        XCTAssertEqual(saved.map(\.id), [product.id])
    }

    func test_addProduct_doesNotDuplicateSameVariant() async {
        let (sut, store) = makeSUT()
        let product = Product.fixture(id: "product-1")
        let selected = SelectedProduct(product: product)

        await sut.addProduct(selected)
        await sut.addProduct(selected)

        let content = await sut.getBagContent()
        XCTAssertEqual(content.count, 1)
        // Duplicate add short-circuits, so only one save invocation.
        XCTAssertEqual(store.saveInvocations.count, 1)
    }

    func test_addProduct_keepsDifferentVariantsOfSameProduct() async {
        let (sut, _) = makeSUT()
        let blue = Product.Variant.fixture(sku: "sku-blue")
        let red = Product.Variant.fixture(sku: "sku-red")
        let product = Product.fixture(id: "p-1", defaultVariant: blue, variants: [blue, red])

        await sut.addProduct(SelectedProduct(product: product, selectedVariant: blue))
        await sut.addProduct(SelectedProduct(product: product, selectedVariant: red))

        let content = await sut.getBagContent()
        XCTAssertEqual(content.count, 2)
    }

    // MARK: - removeProduct

    func test_removeProduct_removesMatchingEntry() async {
        let (sut, _) = makeSUT()
        let product = SelectedProduct(product: .fixture(id: "product-1"))
        await sut.addProduct(product)

        await sut.removeProduct(product)

        let content = await sut.getBagContent()
        XCTAssertTrue(content.isEmpty)
    }

    func test_removeProduct_persistsToStore() async throws {
        let (sut, store) = makeSUT()
        let product = SelectedProduct(product: .fixture(id: "product-1"))
        await sut.addProduct(product)

        await sut.removeProduct(product)

        // 1 save on add + 1 on remove
        XCTAssertEqual(store.saveInvocations.count, 2)
        let lastSave = try XCTUnwrap(store.saveInvocations.last)
        XCTAssertTrue(lastSave.isEmpty)
    }

    func test_removeProduct_doesNotAffectOtherProducts() async {
        let (sut, _) = makeSUT()
        let keep = SelectedProduct(product: .fixture(id: "keep"))
        let remove = SelectedProduct(product: .fixture(id: "remove"))
        await sut.addProduct(keep)
        await sut.addProduct(remove)

        await sut.removeProduct(remove)

        let remaining = await sut.getBagContent()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.product.id, "keep")
    }

    func test_removeProduct_isNoOp_whenProductNotInBag() async {
        let (sut, _) = makeSUT()
        await sut.addProduct(SelectedProduct(product: .fixture(id: "keep")))

        await sut.removeProduct(SelectedProduct(product: .fixture(id: "missing")))

        let content = await sut.getBagContent()
        XCTAssertEqual(content.count, 1)
    }

    // MARK: - Caching

    func test_storeLoadedOnceAtInit_notOnEveryRead() async {
        let (sut, store) = makeSUT()

        _ = await sut.getBagContent()
        await sut.addProduct(SelectedProduct(product: .fixture(id: "p1")))
        _ = await sut.getBagContent()

        // Hydrated once at init; reads/writes are served from the in-memory cache.
        XCTAssertEqual(store.loadCount, 1)
    }

    func test_getContent_isServedFromCache_notReReadFromStore() async {
        let (sut, store) = makeSUT(initialContent: [SelectedProduct(product: .fixture(id: "p1"))])
        // Mutate the store behind the service's back — a cached read must ignore it.
        store.loadStub = [SelectedProduct(product: .fixture(id: "external"))]

        let content = await sut.getBagContent()

        XCTAssertEqual(content.map(\.product.id), ["p1"])
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
