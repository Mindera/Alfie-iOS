import Mocks
import Model
import ProductDetails
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

    // MARK: - WishlistViewModel.productCardViewModel(for:)

    func test_productCardViewModel_hidesSizeFields_whenSelectedProductHasSize() {
        let cardViewModel = makeProductCardViewModel(variantSize: .fixture(value: "M"))

        XCTAssertNil(cardViewModel.sizeTitle)
        XCTAssertNil(cardViewModel.size)
    }

    func test_productCardViewModel_hidesSizeFields_whenSelectedProductHasNoSize() {
        let cardViewModel = makeProductCardViewModel(variantSize: nil)

        XCTAssertNil(cardViewModel.sizeTitle)
        XCTAssertNil(cardViewModel.size)
    }

    // MARK: - Helpers

    private func makeSUT(
        navigate: @escaping (WishlistRoute) -> Void = { _ in }
    ) -> WishlistViewModel {
        let dependencies = WishlistDependencyContainer(
            wishlistService: MockWishlistService(),
            analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker()
        )
        return WishlistViewModel(
            hasNavigationSeparator: false,
            dependencies: dependencies,
            navigate: navigate
        )
    }

    private func makeProductCardViewModel(variantSize: Product.ProductSize?) -> VerticalProductCardViewModel {
        let colour = Product.Colour.fixture(id: "green", name: "Green")
        let variant = Product.Variant.fixture(size: variantSize, colour: colour)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        let selected = SelectedProduct(product: product, selectedVariant: variant)
        return makeSUT().productCardViewModel(for: selected)
    }
}
