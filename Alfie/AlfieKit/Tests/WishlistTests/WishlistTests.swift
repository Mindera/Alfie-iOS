import Mocks
import Model
import ProductDetails
import TestUtils
import XCTest
@testable import Wishlist

final class WishlistTests: XCTestCase {
    // MARK: - WishlistViewModel.didTapAddToBag

    func test_didTapAddToBag_navigatesToProductDetailsWithSelectedProduct() {
        let colour = Product.Colour.fixture(id: "green", name: "Green")
        let variant = Product.Variant.fixture(size: .fixture(value: "M"), colour: colour)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        let selected = SelectedProduct(product: product, selectedVariant: variant)
        var capturedRoutes: [WishlistRoute] = []
        let sut = makeSUT(navigate: { capturedRoutes.append($0) })

        sut.didTapAddToBag(for: selected)

        XCTAssertEqual(
            capturedRoutes,
            [.productDetails(.productDetails(.selectedProduct(selected)))]
        )
    }

    // MARK: - WishlistViewModel.didSelectDelete

    func test_didSelectDelete_removesProductFromWishlistByProductId() {
        let blueVariant = Product.Variant.fixture(colour: .fixture(id: "blue", name: "Blue"))
        let redVariant = Product.Variant.fixture(colour: .fixture(id: "red", name: "Red"))
        let product = Product.fixture(id: "product-1", defaultVariant: redVariant, variants: [blueVariant, redVariant])
        let wishlistService = MockWishlistService()
        wishlistService.addProduct(SelectedProduct(product: product, selectedVariant: blueVariant))
        wishlistService.addProduct(SelectedProduct(product: product, selectedVariant: redVariant))
        let sut = makeSUT(wishlistService: wishlistService)

        sut.didSelectDelete(for: SelectedProduct(product: product, selectedVariant: redVariant))

        XCTAssertTrue(wishlistService.getWishlistContent().isEmpty)
    }

    func test_didSelectDelete_refreshesPublishedProducts() {
        let product = Product.fixture(id: "product-1")
        let wishlistService = MockWishlistService()
        wishlistService.addProduct(SelectedProduct(product: product))
        let sut = makeSUT(wishlistService: wishlistService)
        XCTAssertEqual(sut.products.count, 1)

        sut.didSelectDelete(for: SelectedProduct(product: product))

        XCTAssertTrue(sut.products.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(
        wishlistService: WishlistServiceProtocol = MockWishlistService(),
        navigate: @escaping (WishlistRoute) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> WishlistViewModel {
        let dependencies = WishlistDependencyContainer(
            wishlistService: wishlistService,
            analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker()
        )
        let sut = WishlistViewModel(
            hasNavigationSeparator: false,
            dependencies: dependencies,
            navigate: navigate
        )
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
}
