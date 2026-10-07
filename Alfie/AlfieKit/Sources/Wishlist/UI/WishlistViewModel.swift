import Foundation
import Model

public final class WishlistViewModel: WishlistViewModelProtocol {
    @Published public private(set) var state: ViewState<[SelectedProduct], Never> = .loading
    @Published public private(set) var undoableRemoval: WishlistRemoval?

    public var hasNavigationSeparator: Bool
    private let dependencies: WishlistDependencyContainer
    private let navigate: (WishlistRoute) -> Void
    private var visit = 0

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

    public func viewDidDisappear() {
        visit += 1
        undoableRemoval = nil
    }

    public func viewDidAppear() {
        Task { @MainActor in
            await reload()
        }
    }

    public func didTapProduct(_ selectedProduct: SelectedProduct) {
        openProductDetails(for: selectedProduct)
    }

    public func didSelectDelete(for selectedProduct: SelectedProduct) {
        let productId = selectedProduct.product.id
        let visit = visit
        undoableRemoval = nil
        Task { @MainActor in
            let removal = await dependencies.wishlistService.removeProduct(withId: productId)
            dependencies.analytics.trackRemoveFromWishlist(productID: productId)
            await reload()
            guard visit == self.visit else { return }

            undoableRemoval = removal
        }
    }

    public func didTapUndoRemoval() {
        guard let removal = undoableRemoval else { return }

        undoableRemoval = nil
        Task { @MainActor in
            await dependencies.wishlistService.restore(removal)
            dependencies.analytics.trackAddToWishlist(productID: removal.productId)
            await reload()
        }
    }

    public func didDismissRemovalSnackbar() {
        undoableRemoval = nil
    }

    public func didTapAddToBag(for selectedProduct: SelectedProduct) {
        openProductDetails(for: selectedProduct)
    }

    private func openProductDetails(for selectedProduct: SelectedProduct) {
        navigate(.productDetails(.productDetails(.selectedProduct(selectedProduct))))
    }

    @MainActor
    private func reload() async {
        state = .success(await dependencies.wishlistService.getWishlistContent())
    }
}
