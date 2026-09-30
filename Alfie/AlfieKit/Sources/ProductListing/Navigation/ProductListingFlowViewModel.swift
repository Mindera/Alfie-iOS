import Core
import Foundation
import Model
import ProductDetails
import SwiftUI
import Web

public final class ProductListingFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = ProductListingRoute
    @Published public var path = NavigationPath()
    private let dependencies: ProductListingFlowDependencyContainer
    private let productListingScreenConfiguration: ProductListingScreenConfiguration

    public init(
        dependencies: ProductListingFlowDependencyContainer,
        productListingScreenConfiguration: ProductListingScreenConfiguration
    ) {
        self.dependencies = dependencies
        self.productListingScreenConfiguration = productListingScreenConfiguration
    }

    // MARK: - View Models for ProductListingRoute

    func makeProductListingViewModel() -> some ProductListingViewModelProtocol {
        ProductListingViewModel(
            dependencies: dependencies.productListingDependencyContainer,
            category: productListingScreenConfiguration.category,
            searchText: productListingScreenConfiguration.searchText,
            urlQueryParameters: productListingScreenConfiguration.urlQueryParameters,
            mode: productListingScreenConfiguration.mode,
            navigate: { [weak self] in self?.navigate($0) },
            showSearch: {},
            goBack: {},
            editSearchTerm: {}
        )
    }

    func makeProductListingViewModel(
        configuration: ProductListingScreenConfiguration
    ) -> some ProductListingViewModelProtocol {
        ProductListingViewModel(
            dependencies: dependencies.productListingDependencyContainer,
            category: configuration.category,
            searchText: configuration.searchText,
            urlQueryParameters: configuration.urlQueryParameters,
            mode: configuration.mode,
            navigate: { [weak self] in self?.navigate($0) },
            showSearch: {},
            goBack: {},
            editSearchTerm: {}
        )
    }

    func makeProductDetailsViewModel(
        configuration: ProductDetailsConfiguration
    ) -> some ProductDetailsViewModelProtocol {
        ProductDetailsViewModel(
            configuration: configuration,
            dependencies: dependencies.productDetailsDependencyContainer,
            goBackAction: { [weak self] in self?.pop() },
            openWebfeatureAction: { [weak self] in self?.navigate(.productDetails(.webFeature($0))) },
            openProductAction: { [weak self] in self?.navigate(.productDetails(.productDetails(.product($0)))) }
        )
    }

    func makeWebViewModel(feature: WebFeature) -> some WebViewModelProtocol {
        WebViewModel(webFeature: feature, dependencies: dependencies.webDependencyContainer)
    }
}
