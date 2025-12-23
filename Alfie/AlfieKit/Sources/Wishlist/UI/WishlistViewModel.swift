import Foundation
import Model
import SharedUI

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
        products = dependencies.wishlistService.getWishlistContent()
    }

    // MARK: - WishListViewModelProtocol

    public func viewDidAppear() {
        products = dependencies.wishlistService.getWishlistContent()
    }

    public func didTapProduct(_ selectedProduct: SelectedProduct) {
        navigate(
            .productDetails(.productDetails(.selectedProduct(selectedProduct)))
        )
    }

    public func didSelectDelete(for selectedProduct: SelectedProduct) {
        dependencies.wishlistService.removeProduct(selectedProduct)
        dependencies.analytics.trackRemoveFromWishlist(productID: selectedProduct.product.id)
        products = dependencies.wishlistService.getWishlistContent()
    }

    public func didTapAddToBag(for selectedProduct: SelectedProduct) {
        dependencies.bagService.addProduct(selectedProduct)
        dependencies.analytics.trackAddToBag(productID: selectedProduct.product.id)
    }

    public func didTapMyAccount() {
        navigate(.myAccount(.myAccount))
    }

    public func productCardViewModel(for selectedProduct: SelectedProduct) -> VerticalProductCardViewModel {
        .init(
            configuration: .init(size: .medium, hideDetails: false, actionType: .remove),
            productId: selectedProduct.id,
            image: selectedProduct.media.first?.asImage?.url,
            designer: selectedProduct.brand.name,
            name: selectedProduct.name,
            priceType: selectedProduct.priceType,
            colorTitle: L10n.Product.Color.title + ":",
            color: selectedProduct.colour?.name ?? "",
            sizeTitle: L10n.Product.Size.title + ":",
            size: selectedProduct.size == nil ? L10n.Product.OneSize.title : selectedProduct.sizeText,
            addToBagTitle: L10n.Product.AddToBag.Button.cta,
            outOfStockTitle: L10n.Product.OutOfStock.Button.cta,
            isAddToBagDisabled: selectedProduct.stock == .zero
        )
    }
}
