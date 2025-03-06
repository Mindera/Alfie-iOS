import Foundation
import Models
import SharedUI

final class WishlistViewModel: WishlistViewModelProtocol {
    @Published private(set) var products: [SelectedProduct]

    private let dependencies: WishlistDependencyContainer

    init(dependencies: WishlistDependencyContainer) {
        self.dependencies = dependencies
        products = dependencies.wishlistService.getWishlistContent()
    }

    // MARK: - WishListViewModelProtocol

    func viewDidAppear() {
        products = dependencies.wishlistService.getWishlistContent()
    }

    func didSelectDelete(for selectedProduct: SelectedProduct) {
        dependencies.wishlistService.removeProduct(selectedProduct)
        dependencies.analytics.trackRemoveFromWishlist(productID: selectedProduct.product.id)
        products = dependencies.wishlistService.getWishlistContent()
    }

    func didTapAddToBag(for selectedProduct: SelectedProduct) {
        dependencies.bagService.addProduct(selectedProduct)
        dependencies.analytics.trackAddToBag(productID: selectedProduct.product.id)
    }

    func productCardViewModel(for selectedProduct: SelectedProduct) -> VerticalProductCardViewModel {
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
