import Foundation
import Models

final class WishlistViewModel: WishlistViewModelProtocol {
    @Published private(set) var products: [SelectionProduct]

    private let dependencies: WishlistDependencyContainer

    init(dependencies: WishlistDependencyContainer) {
        self.dependencies = dependencies
        products = dependencies.wishlistService.getWishlistContent()
    }

    // MARK: - WishListViewModelProtocol

    func viewDidAppear() {
        products = dependencies.wishlistService.getWishlistContent()
    }

    func didSelectDelete(for product: SelectionProduct) {
        dependencies.wishlistService.removeProduct(product.id)
        dependencies.analytics.track(
            .action(
                .removeFromWishlist,
                [
                    .screenName: AnalyticsScreenName.wishlist.rawValue,
                    .productID: product.id,
                ]
            )
        )
        products = dependencies.wishlistService.getWishlistContent()
    }

    func didTapAddToBag(for product: SelectionProduct) {
        dependencies.bagService.addProduct(product)
        dependencies.analytics.track(
            .action(
                .addToBag,
                [
                    .screenName: AnalyticsScreenName.wishlist.rawValue,
                    .productID: product.id,
                ]
            )
        )
    }

    func productCardViewModel(for product: SelectionProduct) -> VerticalProductCardViewModel {
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
