@testable import Core
import Mocks
import Model
import TestUtils
import XCTest

final class WishlistServiceTests: XCTestCase {

    // MARK: - init

    func test_init_loadsContentFromStore() {
        let stored = [
            SelectedProduct(product: .fixture(id: "p1")),
            SelectedProduct(product: .fixture(id: "p2"))
        ]
        let (sut, _) = makeSUT(initialContent: stored)

        XCTAssertEqual(sut.getWishlistContent().map(\.id), stored.map(\.id))
    }

    func test_init_withEmptyStore_returnsEmptyContent() {
        let (sut, _) = makeSUT()

        XCTAssertTrue(sut.getWishlistContent().isEmpty)
    }

    func test_init_doesNotPersistOnLoad() {
        let (_, store) = makeSUT(initialContent: [SelectedProduct(product: .fixture(id: "p1"))])

        XCTAssertTrue(store.saveInvocations.isEmpty)
    }

    // MARK: - addProduct

    func test_addProduct_appendsProductToWishlist() {
        let (sut, _) = makeSUT()
        let product = Product.fixture(id: "product-1")

        sut.addProduct(SelectedProduct(product: product))

        XCTAssertEqual(sut.getWishlistContent().count, 1)
        XCTAssertEqual(sut.getWishlistContent().first?.product.id, "product-1")
    }

    func test_addProduct_persistsToStore() throws {
        let (sut, store) = makeSUT()
        let product = SelectedProduct(product: .fixture(id: "p1"))

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

        XCTAssertEqual(sut.getWishlistContent().count, 1)
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

        XCTAssertEqual(sut.getWishlistContent().count, 2)
    }

    // MARK: - removeProduct(withId:)

    func test_removeProduct_withId_removesEntryMatchingProductId() {
        let (sut, _) = makeSUT()
        let product = Product.fixture(id: "product-1")
        sut.addProduct(SelectedProduct(product: product))

        sut.removeProduct(withId: "product-1")

        XCTAssertTrue(sut.getWishlistContent().isEmpty)
    }

    func test_removeProduct_withId_persistsToStore() throws {
        let (sut, store) = makeSUT()
        sut.addProduct(SelectedProduct(product: .fixture(id: "product-1")))

        sut.removeProduct(withId: "product-1")

        // 1 save on add + 1 on remove
        XCTAssertEqual(store.saveInvocations.count, 2)
        let lastSave = try XCTUnwrap(store.saveInvocations.last)
        XCTAssertTrue(lastSave.isEmpty)
    }

    func test_removeProduct_withId_removesAllEntriesMatchingProductId() {
        let (sut, _) = makeSUT()
        let blueVariant = Product.Variant.fixture(colour: .fixture(id: "blue", name: "Blue"))
        let redVariant = Product.Variant.fixture(colour: .fixture(id: "red", name: "Red"))
        let product = Product.fixture(id: "product-1", defaultVariant: redVariant, variants: [blueVariant, redVariant])
        sut.addProduct(SelectedProduct(product: product, selectedVariant: blueVariant))
        sut.addProduct(SelectedProduct(product: product, selectedVariant: redVariant))
        XCTAssertEqual(sut.getWishlistContent().count, 2)

        sut.removeProduct(withId: "product-1")

        XCTAssertTrue(sut.getWishlistContent().isEmpty)
    }

    func test_removeProduct_withId_doesNotAffectOtherProducts() {
        let (sut, _) = makeSUT()
        sut.addProduct(SelectedProduct(product: Product.fixture(id: "keep")))
        sut.addProduct(SelectedProduct(product: Product.fixture(id: "remove")))

        sut.removeProduct(withId: "remove")

        let remaining = sut.getWishlistContent()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.product.id, "keep")
    }

    func test_removeProduct_withId_isNoOp_whenProductIdNotInWishlist() {
        let (sut, _) = makeSUT()
        sut.addProduct(SelectedProduct(product: Product.fixture(id: "keep")))

        sut.removeProduct(withId: "missing")

        XCTAssertEqual(sut.getWishlistContent().count, 1)
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
