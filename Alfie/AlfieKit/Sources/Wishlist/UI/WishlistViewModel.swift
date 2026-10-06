import Foundation
import Model

public final class WishlistViewModel: WishlistViewModelProtocol {
    @Published public private(set) var state: ViewState<[SelectedProduct], Never> = .loading

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
    }

    // MARK: - WishListViewModelProtocol

    public func viewDidAppear() {
        Task { @MainActor in
            await reload()
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
            await reload()
        }
    }

    public func didTapAddToBag(for selectedProduct: SelectedProduct) {
        navigate(.productDetails(.productDetails(.selectedProduct(selectedProduct))))
    }

    @MainActor
    private func reload() async {
        state = .success(await dependencies.wishlistService.getWishlistContent())
    }
}
