import Foundation
import Models

final class WishlistViewModel: WishlistViewModelProtocol {
    @Published private(set) var products: [SelectionProduct]

    private let dependencies: WishlistDependencyContainerProtocol

    init(dependencies: WishlistDependencyContainerProtocol) {
        self.dependencies = dependencies
        products = dependencies.wishlistService.getWishlistContent()
    }

    // MARK: - WishListViewModelProtocol

    func viewDidAppear() {
        products = dependencies.wishlistService.getWishlistContent()
    }

    func didSelectDelete(for product: SelectionProduct) {
        dependencies.wishlistService.removeProduct(product.id)
        products = dependencies.wishlistService.getWishlistContent()
    }

    func didTapAddToBag(for product: SelectionProduct) {
        dependencies.bagService.addProduct(product)
    }

    func productCardViewModel(for product: SelectionProduct) -> VerticalProductCardViewModel {
        .init(
            configuration: .init(size: .medium, hideDetails: false, actionType: .remove),
            productId: product.id,
            image: product.media.first?.asImage?.url,
            designer: product.brand.name,
            name: product.name,
            priceType: product.priceType,
            colorTitle: L10n.$productColorTitle + ":",
            color: product.colour?.name ?? "",
            sizeTitle: L10n.$productSizeTitle + ":",
            size: product.size == nil ? L10n.$productOneSizeTitle : product.sizeText,
            addToBagTitle: L10n.$productAddToBagButtonCTA,
            outOfStockTitle: L10n.$productOutOfStockButtonCTA,
            isAddToBagDisabled: product.stock == .zero
        )
    }
}
