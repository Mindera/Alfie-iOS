import Foundation
import Models
import SharedUI

final class WishlistViewModel: WishlistViewModelProtocol {
    @Published private(set) var products: [WishlistProduct]

    private let dependencies: WishlistDependencyContainer

    init(dependencies: WishlistDependencyContainer) {
        self.dependencies = dependencies
        products = dependencies.wishlistService.getWishlistContent()
    }

    // MARK: - WishListViewModelProtocol

    func viewDidAppear() {
        products = dependencies.wishlistService.getWishlistContent()
    }

    func didSelectDelete(for wishlistProduct: WishlistProduct) {
        dependencies.wishlistService.removeProduct(wishlistProduct)
        dependencies.analytics.trackRemoveFromWishlist(productID: wishlistProduct.product.id)
        products = dependencies.wishlistService.getWishlistContent()
    }

    func productCardViewModel(for wishlistProduct: WishlistProduct) -> VerticalProductCardViewModel {
        .init(
            configuration: .init(size: .medium, hideSize: true, actionType: .remove),
            productId: wishlistProduct.id,
            image: wishlistProduct.media.first?.asImage?.url,
            designer: wishlistProduct.brand.name,
            name: wishlistProduct.name,
            priceType: wishlistProduct.priceType,
            colorTitle: L10n.Product.Color.title + ":",
            color: wishlistProduct.colour?.name ?? "",
            sizeTitle: L10n.Product.Size.title + ":",
            size: wishlistProduct.size == nil ? L10n.Product.OneSize.title : wishlistProduct.sizeText,
            addToBagTitle: L10n.Product.AddToBag.Button.cta,
            outOfStockTitle: L10n.Product.OutOfStock.Button.cta,
            isAddToBagDisabled: wishlistProduct.stock == .zero
        )
    }
}
