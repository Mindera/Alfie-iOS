import Foundation
import Model

public final class WishlistViewModel: WishlistViewModelProtocol {
    @Published public private(set) var products: [SelectedProduct]

    public var hasNavigationSeparator: Bool
    private let dependencies: WishlistDependencyContainer
    private let navigate: (WishlistRoute) -> Void

    public init(
        hasNavigationSeparator: Bool,
        dependencies: WishlistDependencyContainer,
        navigate: @escaping (WishlistRoute) -> Void
    ) {
        self.hasNavigationSeparator = hasNavigationSeparator
        self.dependencies = dependencies
        self.navigate = navigate
        products = []
    }

    // MARK: - WishListViewModelProtocol

    public func viewDidAppear() {
        Task { @MainActor in
            products = await dependencies.wishlistService.getWishlistContent()
        }
    }

    public func didTapProduct(_ selectedProduct: SelectedProduct) {
        navigate(
            .productDetails(.productDetails(.selectedProduct(selectedProduct)))
        )
    }

    public func didSelectDelete(for selectedProduct: SelectedProduct) {
        Task { @MainActor in
            await dependencies.wishlistService.removeProduct(withId: selectedProduct.product.id)
            dependencies.analytics.trackRemoveFromWishlist(productID: selectedProduct.product.id)
            products = await dependencies.wishlistService.getWishlistContent()
        }
    }

    public func didTapAddToBag(for selectedProduct: SelectedProduct) {
        navigate(.productDetails(.productDetails(.selectedProduct(selectedProduct))))
    }
}
