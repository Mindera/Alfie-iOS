import Core
import Foundation
import Model
import ProductDetails
import SwiftUI
import Web

public final class ProductListingFlowViewModel: ObservableObject {
    @Published var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol
    private let productListingScreenConfiguration: ProductListingScreenConfiguration2

    public init(
        serviceProvider: ServiceProviderProtocol,
        productListingScreenConfiguration: ProductListingScreenConfiguration2
    ) {
        self.serviceProvider = serviceProvider
        self.productListingScreenConfiguration = productListingScreenConfiguration
    }

    func makeProductListingViewModel() -> some ProductListingViewModelProtocol2 {
        ProductListingViewModel2(
            dependencies: .init(
                productListingService: ProductListingService(
                    productService: serviceProvider.productService,
                    configuration: .init(type: .plp)
                ),
                plpStyleListProvider: ProductListingStyleProvider2(userDefaults: serviceProvider.userDefaults),
                wishlistService: serviceProvider.wishlistService,
                analytics: serviceProvider.analytics
            ),
            category: productListingScreenConfiguration.category,
            searchText: productListingScreenConfiguration.searchText,
            urlQueryParameters: productListingScreenConfiguration.urlQueryParameters,
            mode: productListingScreenConfiguration.mode
        ) { [weak self] in
            self?.navigate($0)
        }
    }

    func makeProductListingViewModel(
        configuration: ProductListingScreenConfiguration2
    ) -> some ProductListingViewModelProtocol2 {
        ProductListingViewModel2(
            dependencies: .init(
                productListingService: ProductListingService(
                    productService: serviceProvider.productService,
                    configuration: .init(type: .plp)
                ),
                plpStyleListProvider: ProductListingStyleProvider2(userDefaults: serviceProvider.userDefaults),
                wishlistService: serviceProvider.wishlistService,
                analytics: serviceProvider.analytics
            ),
            category: configuration.category,
            searchText: configuration.searchText,
            urlQueryParameters: configuration.urlQueryParameters,
            mode: configuration.mode
        ) { [weak self] in
            self?.navigate($0)
        }
    }

    func makeProductDetailsViewModel(
        productID: String,
        product: Product?
    ) -> some ProductDetailsViewModelProtocol2 {
        ProductDetailsViewModel2(
            productId: productID,
            product: product,
            dependencies: .init(
                productService: serviceProvider.productService,
                webUrlProvider: serviceProvider.webUrlProvider,
                bagService: serviceProvider.bagService,
                wishlistService: serviceProvider.wishlistService,
                configurationService: serviceProvider.configurationService,
                analytics: serviceProvider.analytics
            ),
            goBackAction: { [weak self] in self?.pop() },
            openWebfeatureAction: { [weak self] in self?.navigate(.productDetails(.webFeature($0))) }
        )
    }

    func makeWebViewModel(feature: WebFeature) -> some WebViewModelProtocol2 {
        WebViewModel2(
            webFeature: feature,
            dependencies: WebDependencyContainer2(
                deepLinkService: serviceProvider.deepLinkService,
                webViewConfigurationService: serviceProvider.webViewConfigurationService,
                webUrlProvider: serviceProvider.webUrlProvider
            )
        )
    }

    private func navigate(_ route: ProductListingRoute) {
        path.append(route)
    }

    public func popToRoot() {
        path.removeLast(path.count)
    }

    func pop() {
        path.removeLast()
    }
}
