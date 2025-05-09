import Foundation
import Model
import SharedUI

public final class WishlistViewModel2: WishlistViewModelProtocol2 {
    @Published public private(set) var products: [SelectionProduct]

    public var hasNavigationSeparator: Bool
    private let dependencies: WishlistDependencyContainer2
    private let navigate: (WishlistRoute) -> Void

    public init(
        hasNavigationSeparator: Bool,
        dependencies: WishlistDependencyContainer2,
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

    public func didSelectDelete(for product: SelectionProduct) {
        dependencies.wishlistService.removeProduct(product.id)
        dependencies.analytics.trackRemoveFromWishlist(productID: product.id)
        products = dependencies.wishlistService.getWishlistContent()
    }

    public func didTapAddToBag(for product: SelectionProduct) {
        dependencies.bagService.addProduct(product)
        dependencies.analytics.trackAddToBag(productID: product.id)
    }

    public func didTapMyAccount() {
        navigate(.myAccount(.myAccount))
    }

    public func productCardViewModel(for product: SelectionProduct) -> VerticalProductCardViewModel {
        .init(
            configuration: .init(size: .medium, hideDetails: false, actionType: .remove),
            productId: product.id,
            image: product.media.first?.asImage?.url,
            designer: product.brand.name,
            name: product.name,
            priceType: product.priceType,
            colorTitle: L10n.Product.Color.title + ":",
            color: product.colour?.name ?? "",
            sizeTitle: L10n.Product.Size.title + ":",
            size: product.size == nil ? L10n.Product.OneSize.title : product.sizeText,
            addToBagTitle: L10n.Product.AddToBag.Button.cta,
            outOfStockTitle: L10n.Product.OutOfStock.Button.cta,
            isAddToBagDisabled: product.stock == .zero
        )
    }
}
