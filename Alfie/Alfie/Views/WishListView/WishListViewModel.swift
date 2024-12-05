import Foundation
import Models

final class WishListViewModel: WishListViewModelProtocol {
    @Published private(set) var products: [Product]

    var toolbarModifierViewModel: DefaultToolbarModifierViewModelProtocol {
        DefaultToolbarModifierViewModel(configurationService: dependencies.configurationService)
    }

    private let dependencies: WishListDependencyContainerProtocol

    init(dependencies: WishListDependencyContainerProtocol) {
        self.dependencies = dependencies
        products = dependencies.bagService.getBagContent()
    }

    // MARK: - WishListViewModelProtocol

    func viewDidAppear() {
        products = dependencies.wishListService.getWishListContent()
    }

    func didSelectDelete(for product: Product) {
        dependencies.wishListService.removeProduct(product)
        products = dependencies.wishListService.getWishListContent()
    }

    func didTapAddToBag(for product: Product) {
        dependencies.bagService.addProduct(product)
    }
}
