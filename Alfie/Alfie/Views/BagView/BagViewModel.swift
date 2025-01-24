import Foundation
import Models

final class BagViewModel: BagViewModelProtocol {
    @Published private(set) var products: [SelectionProduct]

    private let dependencies: BagDependencyContainer

    init(dependencies: BagDependencyContainer) {
        self.dependencies = dependencies
        products = dependencies.bagService.getBagContent()
    }

    // MARK: - BagViewModelProtocol

    func viewDidAppear() {
        products = dependencies.bagService.getBagContent()
    }

    func didSelectDelete(for product: SelectionProduct) {
        dependencies.bagService.removeProduct(product)
        products = dependencies.bagService.getBagContent()
    }

    func productCardViewModel(for product: SelectionProduct) -> HorizontalProductCardViewModel {
        .init(
            image: product.media.first?.asImage?.url,
            designer: product.brand.name,
            name: product.name,
            colorTitle: L10n.$productColorTitle + ":",
            color: product.colour?.name ?? "",
            sizeTitle: L10n.$productSizeTitle + ":",
            size: product.size == nil ? L10n.$productOneSizeTitle : product.sizeText,
            priceType: product.priceType
        )
    }
}
