import Foundation
import Model
import SharedUI

final class BagViewModel: BagViewModelProtocol {
    @Published private(set) var products: [SelectedProduct]
    var isWishlistEnabled: Bool

    private let dependencies: BagDependencyContainer
    private let navigate: (BagRoute) -> Void

    init(
        isWishlistEnabled: Bool,
        dependencies: BagDependencyContainer,
        navigate: @escaping (BagRoute) -> Void
    ) {
        self.isWishlistEnabled = isWishlistEnabled
        self.dependencies = dependencies
        self.navigate = navigate
        products = dependencies.bagService.getBagContent()
    }

    // MARK: - BagViewModelProtocol

    func viewDidAppear() {
        products = dependencies.bagService.getBagContent()
    }

    func didTapProduct(_ selectedProduct: SelectedProduct) {
        navigate(.productDetails(.productDetails(.selectedProduct(selectedProduct))))
    }

    func didSelectDelete(for selectedProduct: SelectedProduct) {
        dependencies.bagService.removeProduct(selectedProduct)
        products = dependencies.bagService.getBagContent()
        dependencies.analytics.trackRemoveFromBag(productID: selectedProduct.product.id)
    }

    func didTapMyAccount() {
        navigate(.myAccount(.myAccount))
    }

    func didTapWishlist() {
        navigate(.wishlist(.wishlist))
    }

    func productCardViewModel(for selectedProduct: SelectedProduct) -> HorizontalProductCardViewModel {
        .init(
            image: selectedProduct.media.first?.asImage?.url,
            designer: selectedProduct.brand.name,
            name: selectedProduct.name,
            colorTitle: L10n.Product.Color.title + ":",
            color: selectedProduct.colour?.name ?? "",
            sizeTitle: L10n.Product.Size.title + ":",
            size: selectedProduct.size == nil ? L10n.Product.OneSize.title : selectedProduct.sizeText,
            priceType: selectedProduct.priceType
        )
    }
}
