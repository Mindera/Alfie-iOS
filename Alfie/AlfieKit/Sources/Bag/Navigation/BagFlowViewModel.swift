import Model
import ProductDetails
import SwiftUI
import Web

public final class BagFlowViewModel: BagFlowViewModelProtocol {
    public typealias Route = BagRoute
    @Published public var path = NavigationPath()
    private let dependencies: BagFlowDependencyContainer

    public init(dependencies: BagFlowDependencyContainer) {
        self.dependencies = dependencies
    }

    // MARK: - View Models for BagRoute

    public func makeBagViewModel() -> BagViewModel {
        BagViewModel(dependencies: dependencies.bagDependencyContainer) { [weak self] in
            self?.navigate($0)
        }
    }

    public func makeProductDetailsViewModel(configuration: ProductDetailsConfiguration) -> ProductDetailsViewModel {
        ProductDetailsViewModel(
            configuration: configuration,
            dependencies: dependencies.productDetailsDependencyContainer,
            goBackAction: { [weak self] in self?.pop() },
            openWebfeatureAction: { [weak self] in self?.navigate(.productDetails(.webFeature($0))) },
            openProductAction: { [weak self] in self?.navigate(.productDetails(.productDetails(.product($0)))) }
        )
    }

    public func makeWebViewModel(feature: WebFeature) -> WebViewModel {
        WebViewModel(
            webFeature: feature,
            dependencies: dependencies.webDependencyContainer
        )
    }

    // MARK: - FlowViewModelProtocol

    public func navigate(_ route: BagRoute) {
        if case .bag = route {
            popToRoot()
        } else {
            path.append(route)
        }
    }
}
