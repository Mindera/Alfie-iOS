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
        dependencies.analytics.track(
            .action(
                .removeFromBag,
                [
                    .screenName: AnalyticsScreenName.bag.rawValue,
                    .productID: product.id,
                ]
            )
        )
    }

    func productCardViewModel(for product: SelectionProduct) -> HorizontalProductCardViewModel {
        .init(
            image: product.media.first?.asImage?.url,
            designer: product.brand.name,
            name: product.name,
            colorTitle: L10n.Product.Color.title + ":",
            color: product.colour?.name ?? "",
            sizeTitle: L10n.Product.Size.title + ":",
            size: product.size == nil ? L10n.Product.OneSize.title : product.sizeText,
            priceType: product.priceType
        )
    }
}
