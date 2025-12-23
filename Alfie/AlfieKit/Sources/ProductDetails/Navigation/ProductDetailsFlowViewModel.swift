import Model
import SwiftUI
import Web

public final class ProductDetailsFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = ProductDetailsRoute
    @Published public var path = NavigationPath()
    private let dependencies: ProductDetailsFlowDependencyContainer
    private let configuration: ProductDetailsConfiguration

    public init(
        configuration: ProductDetailsConfiguration,
        dependencies: ProductDetailsFlowDependencyContainer
    ) {
        self.configuration = configuration
        self.dependencies = dependencies
    }

    // MARK: - View Models for ProductDetailsRoute

    func makeProductDetailsViewModel() -> some ProductDetailsViewModelProtocol {
        ProductDetailsViewModel(
            configuration: configuration,
            dependencies: dependencies.productDetailsDependencyContainer,
            goBackAction: { [weak self] in self?.pop() },
            openWebfeatureAction: { [weak self] in self?.navigate(.webFeature($0)) }
        )
    }

    func makeProductDetailsViewModel(
        configuration: ProductDetailsConfiguration
    ) -> some ProductDetailsViewModelProtocol {
        ProductDetailsViewModel(
            configuration: configuration,
            dependencies: dependencies.productDetailsDependencyContainer,
            goBackAction: { [weak self] in self?.pop() },
            openWebfeatureAction: { [weak self] in self?.navigate(.webFeature($0)) }
        )
    }

    func makeWebViewModel(feature: WebFeature) -> some WebViewModelProtocol {
        WebViewModel(
            webFeature: feature,
            dependencies: dependencies.webDependencyContainer
        )
    }
}
