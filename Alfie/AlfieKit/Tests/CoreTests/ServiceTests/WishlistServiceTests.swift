@testable import Core
import Mocks
import Model
import TestUtils
import XCTest

final class WishlistServiceTests: XCTestCase {

    // MARK: - init

    func test_init_loadsContentFromStore() async {
        let stored = [
            SelectedProduct(product: .fixture(id: "p1")),
            SelectedProduct(product: .fixture(id: "p2"))
        ]
        let (sut, _) = makeSUT(initialContent: stored)

        let content = await sut.getWishlistContent()
        XCTAssertEqual(content.map(\.id), stored.map(\.id))
    }

    func test_init_withEmptyStore_returnsEmptyContent() async {
        let (sut, _) = makeSUT()

        let content = await sut.getWishlistContent()
        XCTAssertTrue(content.isEmpty)
    }

    func test_init_doesNotPersistOnLoad() {
        let (_, store) = makeSUT(initialContent: [SelectedProduct(product: .fixture(id: "p1"))])

        XCTAssertTrue(store.saveInvocations.isEmpty)
    }

    // MARK: - addProduct

    func test_addProduct_appendsProductToWishlist() async {
        let (sut, _) = makeSUT()
        let product = Product.fixture(id: "product-1")

        await sut.addProduct(SelectedProduct(product: product))

        let content = await sut.getWishlistContent()
        XCTAssertEqual(content.count, 1)
        XCTAssertEqual(content.first?.product.id, "product-1")
    }

    func test_addProduct_persistsToStore() async throws {
        let (sut, store) = makeSUT()
        let product = SelectedProduct(product: .fixture(id: "p1"))

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

        let content = await sut.getWishlistContent()
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

        let content = await sut.getWishlistContent()
        XCTAssertEqual(content.count, 2)
    }

    // MARK: - removeProduct(withId:)

    func test_removeProduct_withId_removesEntryMatchingProductId() async {
        let (sut, _) = makeSUT()
        let product = Product.fixture(id: "product-1")
        await sut.addProduct(SelectedProduct(product: product))

        await sut.removeProduct(withId: "product-1")

        let content = await sut.getWishlistContent()
        XCTAssertTrue(content.isEmpty)
    }

    func test_removeProduct_withId_persistsToStore() async throws {
        let (sut, store) = makeSUT()
        await sut.addProduct(SelectedProduct(product: .fixture(id: "product-1")))

        await sut.removeProduct(withId: "product-1")

        // 1 save on add + 1 on remove
        XCTAssertEqual(store.saveInvocations.count, 2)
        let lastSave = try XCTUnwrap(store.saveInvocations.last)
        XCTAssertTrue(lastSave.isEmpty)
    }

    func test_removeProduct_withId_removesAllEntriesMatchingProductId() async {
        let (sut, _) = makeSUT()
        let blueVariant = Product.Variant.fixture(colour: .fixture(id: "blue", name: "Blue"))
        let redVariant = Product.Variant.fixture(colour: .fixture(id: "red", name: "Red"))
        let product = Product.fixture(id: "product-1", defaultVariant: redVariant, variants: [blueVariant, redVariant])
        await sut.addProduct(SelectedProduct(product: product, selectedVariant: blueVariant))
        await sut.addProduct(SelectedProduct(product: product, selectedVariant: redVariant))
        let beforeRemoval = await sut.getWishlistContent()
        XCTAssertEqual(beforeRemoval.count, 2)

        await sut.removeProduct(withId: "product-1")

        let content = await sut.getWishlistContent()
        XCTAssertTrue(content.isEmpty)
    }

    func test_removeProduct_withId_doesNotAffectOtherProducts() async {
        let (sut, _) = makeSUT()
        await sut.addProduct(SelectedProduct(product: Product.fixture(id: "keep")))
        await sut.addProduct(SelectedProduct(product: Product.fixture(id: "remove")))

        await sut.removeProduct(withId: "remove")

        let remaining = await sut.getWishlistContent()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.product.id, "keep")
    }

    func test_removeProduct_withId_isNoOp_whenProductIdNotInWishlist() async {
        let (sut, _) = makeSUT()
        await sut.addProduct(SelectedProduct(product: Product.fixture(id: "keep")))

        await sut.removeProduct(withId: "missing")

        let content = await sut.getWishlistContent()
        XCTAssertEqual(content.count, 1)
    }

    // MARK: - Caching

    func test_storeLoadedOnceAtInit_notOnEveryRead() async {
        let (sut, store) = makeSUT()

        _ = await sut.getWishlistContent()
        await sut.addProduct(SelectedProduct(product: .fixture(id: "p1")))
        _ = await sut.getWishlistContent()

        // Hydrated once at init; reads/writes are served from the in-memory cache.
        XCTAssertEqual(store.loadCount, 1)
    }

    func test_getContent_isServedFromCache_notReReadFromStore() async {
        let (sut, store) = makeSUT(initialContent: [SelectedProduct(product: .fixture(id: "p1"))])
        // Mutate the store behind the service's back — a cached read must ignore it.
        store.loadStub = [SelectedProduct(product: .fixture(id: "external"))]

        let content = await sut.getWishlistContent()

        XCTAssertEqual(content.map(\.product.id), ["p1"])
    }

    // MARK: - Helpers

    private func makeSUT(
        initialContent: [SelectedProduct] = [],
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: WishlistService, store: MockWishlistStore) {
        let store = MockWishlistStore(initialContent: initialContent)
        let sut = WishlistService(store: store)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
}
