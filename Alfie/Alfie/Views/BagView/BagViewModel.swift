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

    public func viewDidAppear() {
        products = dependencies.bagService.getBagContent()
    }

    public func didSelectDelete(for productId: String) {
        dependencies.bagService.removeProduct(productId)
        products = dependencies.bagService.getBagContent()
    }

    public func webViewModel() -> any WebViewModelProtocol {
        WebViewModel(
            webFeature: .bag,
            dependencies: WebDependencyContainer(
                deepLinkService: dependencies.deepLinkService,
                webViewConfigurationService: dependencies.webViewConfigurationService,
                webUrlProvider: dependencies.webUrlProvider
            )
        )
    }
}
