import Foundation
import Models

final class BagViewModel: BagViewModelProtocol {
    @Published private(set) var products: [Product]

    private let dependencies: BagDependencyContainerProtocol

    init(dependencies: BagDependencyContainerProtocol) {
        self.dependencies = dependencies
        products = dependencies.bagService.getBagContent()
    }

    // MARK: - BagViewModelProtocol

    func viewDidAppear() {
        products = dependencies.bagService.getBagContent()
    }

    func didSelectDelete(for productId: String) {
        dependencies.bagService.removeProduct(productId)
        products = dependencies.bagService.getBagContent()
    }
}
