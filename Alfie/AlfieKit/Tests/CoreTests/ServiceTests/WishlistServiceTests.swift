@testable import Core
import Mocks
import Model
import XCTest

final class WishlistServiceTests: XCTestCase {
    private var sut: WishlistService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = WishlistService()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - addProduct

    func test_addProduct_appendsProductToWishlist() {
        let product = Product.fixture(id: "product-1")

        sut.addProduct(SelectedProduct(product: product))

        XCTAssertEqual(sut.getWishlistContent().count, 1)
        XCTAssertEqual(sut.getWishlistContent().first?.product.id, "product-1")
    }

    func test_addProduct_doesNotDuplicateSameVariant() {
        let product = Product.fixture(id: "product-1")
        let selected = SelectedProduct(product: product)

        sut.addProduct(selected)
        sut.addProduct(selected)

        XCTAssertEqual(sut.getWishlistContent().count, 1)
    }

    // MARK: - removeProduct(withId:)

    func test_removeProduct_withId_removesEntryMatchingProductId() {
        let product = Product.fixture(id: "product-1")
        sut.addProduct(SelectedProduct(product: product))

        sut.removeProduct(withId: "product-1")

        XCTAssertTrue(sut.getWishlistContent().isEmpty)
    }

    func test_removeProduct_withId_removesAllEntriesMatchingProductId() {
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
        sut.addProduct(SelectedProduct(product: Product.fixture(id: "keep")))
        sut.addProduct(SelectedProduct(product: Product.fixture(id: "remove")))

        sut.removeProduct(withId: "remove")

        let remaining = sut.getWishlistContent()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.product.id, "keep")
    }

    func test_removeProduct_withId_isNoOp_whenProductIdNotInWishlist() {
        sut.addProduct(SelectedProduct(product: Product.fixture(id: "keep")))

        sut.removeProduct(withId: "missing")

        XCTAssertEqual(sut.getWishlistContent().count, 1)
    }
}
