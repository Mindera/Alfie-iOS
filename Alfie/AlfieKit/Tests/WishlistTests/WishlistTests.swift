import Mocks
import Model
import ProductDetails
import Testing
@testable import Wishlist

struct WishlistTests {
    // MARK: - WishlistViewModel.didTapAddToBag

    @Test("didTapAddToBag navigates to PDP with the selected product and does not add to bag")
    func didTapAddToBag_navigatesToProductDetails_andDoesNotAddToBag() {
        let colour = Product.Colour.fixture(id: "green", name: "Green")
        let variant = Product.Variant.fixture(size: .fixture(value: "M"), colour: colour)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        let selected = SelectedProduct(product: product, selectedVariant: variant)
        let bagService = MockBagService()
        var capturedRoutes: [WishlistRoute] = []
        let sut = makeSUT(bagService: bagService, navigate: { capturedRoutes.append($0) })

        sut.didTapAddToBag(for: selected)

        #expect(capturedRoutes == [.productDetails(.productDetails(.selectedProduct(selected)))])
        #expect(bagService.getBagContent().isEmpty)
    }

    // MARK: - WishlistViewModel.productCardViewModel(for:)

    @Test("productCardViewModel hides size fields when the selected product has a size")
    func productCardViewModel_hidesSizeFields_whenSelectedProductHasSize() {
        let cardViewModel = makeProductCardViewModel(variantSize: .fixture(value: "M"))

        #expect(cardViewModel.sizeTitle == nil)
        #expect(cardViewModel.size == nil)
    }

    @Test("productCardViewModel hides size fields when the selected product has no size")
    func productCardViewModel_hidesSizeFields_whenSelectedProductHasNoSize() {
        let cardViewModel = makeProductCardViewModel(variantSize: nil)

        #expect(cardViewModel.sizeTitle == nil)
        #expect(cardViewModel.size == nil)
    }

    // MARK: - Helpers

    private func makeSUT(
        bagService: BagServiceProtocol = MockBagService(),
        navigate: @escaping (WishlistRoute) -> Void = { _ in }
    ) -> WishlistViewModel {
        let dependencies = WishlistDependencyContainer(
            wishlistService: MockWishlistService(),
            bagService: bagService,
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
