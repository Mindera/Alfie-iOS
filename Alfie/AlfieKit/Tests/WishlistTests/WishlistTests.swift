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
        let wishlistService = MockWishlistService(products: [
            SelectedProduct(product: product, selectedVariant: blueVariant),
            SelectedProduct(product: product, selectedVariant: redVariant)
        ])
        let sut = makeSUT(wishlistService: wishlistService)

        // The delete reloads `products` from the service; both variants share `product-1` so all go.
        XCTAssertEmitsValue(
            from: sut.$products,
            where: { $0.isEmpty },
            afterTrigger: { sut.didSelectDelete(for: SelectedProduct(product: product, selectedVariant: redVariant)) }
        )
    }

    func test_didSelectDelete_refreshesPublishedProducts() {
        let product = Product.fixture(id: "product-1")
        let wishlistService = MockWishlistService(products: [SelectedProduct(product: product)])
        let sut = makeSUT(wishlistService: wishlistService)

        XCTAssertEmitsValue(from: sut.$products, where: { $0.count == 1 }, afterTrigger: { sut.viewDidAppear() })

        XCTAssertEmitsValue(
            from: sut.$products,
            where: { $0.isEmpty },
            afterTrigger: { sut.didSelectDelete(for: SelectedProduct(product: product)) }
        )
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
