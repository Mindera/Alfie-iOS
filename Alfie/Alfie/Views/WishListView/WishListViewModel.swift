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
}
