import Combine
import Foundation
import Models
import SharedUI

final class WishlistViewModel: WishlistViewModelProtocol {
    @Published private(set) var products: [WishlistProduct] = []
    private var subscriptions = Set<AnyCancellable>()
    private let dependencies: WishlistDependencyContainer

    init(dependencies: WishlistDependencyContainer) {
        self.dependencies = dependencies

        setupBindigs()
    }

    private func setupBindigs() {
        dependencies.wishlistService.productsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] wishListProducts in
                self?.products = wishListProducts
            }
            .store(in: &subscriptions)
    }

    // MARK: - WishListViewModelProtocol

    func didSelectDelete(for wishlistProduct: WishlistProduct) {
        dependencies.wishlistService.removeProduct(wishlistProduct)
        dependencies.analytics.trackRemoveFromWishlist(productID: wishlistProduct.product.id)
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
