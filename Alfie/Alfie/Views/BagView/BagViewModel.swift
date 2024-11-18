import Foundation
import Models

final class BagViewModel: BagViewModelProtocol {
    private let dependencies: BagDependencyContainerProtocol

    init(dependencies: BagDependencyContainerProtocol) {
        self.dependencies = dependencies
    }

    // MARK: - BagViewModelProtocol

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
