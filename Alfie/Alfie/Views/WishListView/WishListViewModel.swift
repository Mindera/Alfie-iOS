import Foundation
import Models

final class WishListViewModel: WishListViewModelProtocol {
    @Published private(set) var products: [SelectionProduct]

    private let dependencies: WishListDependencyContainerProtocol

    init(dependencies: WishListDependencyContainerProtocol) {
        self.dependencies = dependencies
        products = dependencies.wishListService.getWishListContent()
    }

    // MARK: - WishListViewModelProtocol

    func viewDidAppear() {
        products = dependencies.wishListService.getWishListContent()
    }

    func didSelectDelete(for product: SelectionProduct) {
        dependencies.wishListService.removeProductWith(colourId: product.colour?.id, sizeId: product.size?.id)
        products = dependencies.wishListService.getWishListContent()
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
            colorTitle: LocalizableGeneral.$color + ":",
            color: product.colour?.name ?? "",
            sizeTitle: LocalizableGeneral.$size + ":",
            size: product.size == nil ? LocalizableGeneral.$oneSize : product.sizeText,
            addToBagTitle: LocalizableGeneral.$addToBag,
            outOfStockTitle: LocalizableGeneral.$outOfStock,
            isAddToBagDisabled: product.stock == .zero
        )
    }
}
