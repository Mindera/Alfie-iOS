import Mocks
import Model
import XCTest
@testable import Wishlist

final class WishlistTests: XCTestCase {
    // MARK: - WishlistViewModel.productCardViewModel(for:)

    func test_productCardViewModel_neverPassesSizeFields_evenWhenSelectedProductHasSize() {
        let colour = Product.Colour.fixture(id: "green", name: "Green")
        let variant = Product.Variant.fixture(size: .fixture(value: "M"), colour: colour)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        let selected = SelectedProduct(product: product, selectedVariant: variant)
        let sut = makeSUT()

        let cardViewModel = sut.productCardViewModel(for: selected)

        XCTAssertNil(cardViewModel.sizeTitle)
        XCTAssertNil(cardViewModel.size)
    }

    func test_productCardViewModel_neverPassesSizeFields_whenSelectedProductHasNoSize() {
        let colour = Product.Colour.fixture(id: "green", name: "Green")
        let variant = Product.Variant.fixture(size: nil, colour: colour)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        let selected = SelectedProduct(product: product, selectedVariant: variant)
        let sut = makeSUT()

        let cardViewModel = sut.productCardViewModel(for: selected)

        XCTAssertNil(cardViewModel.sizeTitle)
        XCTAssertNil(cardViewModel.size)
    }

    // MARK: - Helpers

    private func makeSUT() -> WishlistViewModel {
        let dependencies = WishlistDependencyContainer(
            wishlistService: MockWishlistService(),
            bagService: MockBagService(),
            analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker()
        )
        return WishlistViewModel(
            hasNavigationSeparator: false,
            dependencies: dependencies,
            navigate: { _ in }
        )
    }
}
