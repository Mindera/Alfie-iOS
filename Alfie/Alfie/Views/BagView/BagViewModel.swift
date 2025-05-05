import Combine
import Foundation
import Models
import SharedUI

final class BagViewModel: BagViewModelProtocol {
    @Published private(set) var products: [BagProduct] = []
    private var subscriptions = Set<AnyCancellable>()
    private let dependencies: BagDependencyContainer

    init(dependencies: BagDependencyContainer) {
        self.dependencies = dependencies

        setupBindigs()
    }

    private func setupBindigs() {
        dependencies.bagService.productsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bagProducts in
                self?.products = bagProducts
            }
            .store(in: &subscriptions)
    }

    // MARK: - BagViewModelProtocol

    func didSelectDelete(for selectedProduct: BagProduct) {
        dependencies.bagService.removeProduct(selectedProduct)
        dependencies.analytics.trackRemoveFromBag(productID: selectedProduct.product.id)
    }

    func productCardViewModel(for selectedProduct: BagProduct) -> HorizontalProductCardViewModel {
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
