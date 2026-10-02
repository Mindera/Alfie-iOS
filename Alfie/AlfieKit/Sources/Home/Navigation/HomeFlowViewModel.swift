import Combine
import Core
import Model
import MyAccount
import ProductDetails
import ProductListing
import SwiftUI
import TabFlow
import Web
import Wishlist

public final class HomeFlowViewModel: HomeFlowViewModelProtocol {
    public typealias Route = HomeRoute
    @Published public var path = NavigationPath()
    private let dependencies: HomeFlowDependencyContainer
    private let overlays: TabOverlayCoordinator
    public var overlayPublisher: AnyPublisher<TabOverlay?, Never> { overlays.overlayPublisher }

    public init(dependencies: HomeFlowDependencyContainer) {
        self.dependencies = dependencies
        overlays = TabOverlayCoordinator(
            dependencies: .init(
                search: dependencies.searchDependencyContainer,
                scanner: dependencies.scannerDependencyContainer,
                productListing: dependencies.productListingDependencyContainer,
                productDetails: dependencies.productDetailsDependencyContainer,
                web: dependencies.webDependencyContainer
            )
        )
    }

    public func dismissOverlay() {
        overlays.dismiss()
    }

    // MARK: - View Models for HomeRoute

    public func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            dependencies: dependencies.homeDependencyContainer,
            navigate: { [weak self] route in self?.navigate(route) },
            showSearch: overlays.showSearch,
            showScanner: overlays.showScanner
        )
    }

    public func makeAccountViewModel() -> AccountViewModel {
        AccountViewModel(dependencies: dependencies.myAccountDependencyContainer) { [weak self] in
            self?.navigate(.myAccount($0))
        }
    }

    public func makeProductListingViewModel(
        configuration: ProductListingScreenConfiguration
    ) -> ProductListingViewModel {
        ProductListingViewModel(
            dependencies: dependencies.productListingDependencyContainer,
            category: configuration.category,
            searchText: configuration.searchText,
            urlQueryParameters: configuration.urlQueryParameters,
            mode: configuration.mode,
            navigate: { [weak self] in self?.navigate(.productListing($0)) },
            showSearch: overlays.showSearch
        )
    }

    public func makeProductDetailsViewModel(configuration: ProductDetailsConfiguration) -> ProductDetailsViewModel {
        ProductDetailsViewModel(
            configuration: configuration,
            dependencies: dependencies.productDetailsDependencyContainer,
            goBackAction: { [weak self] in self?.pop() },
            openWebfeatureAction: { [weak self] in self?.navigate(.productListing(.productDetails(.webFeature($0)))) },
            openProductAction: { [weak self] in
                self?.navigate(.productListing(.productDetails(.productDetails(.product($0)))))
            }
        )
    }

    public func makeWebViewModel(feature: WebFeature) -> WebViewModel {
        WebViewModel(
            webFeature: feature,
            dependencies: dependencies.webDependencyContainer
        )
    }

    // MARK: - View Models for MyAccountIntent

    public func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView {
        switch intent {
        case .wishlist:
            AnyView(
                WishlistView(viewModel: makeWishlistViewModelForMyAccount())
            )
        }
    }

    public func makeWishlistViewModelForMyAccount() -> WishlistViewModel {
        WishlistViewModel(
            hasNavigationSeparator: true,
            dependencies: dependencies.wishlistDependencyContainer
        ) { [weak self] in
            self?.navigate(.wishlist($0))
        }
    }

    // MARK: - FlowViewModelProtocol

    public func navigate(_ route: HomeRoute) {
        if case .home = route {
            popToRoot()
        } else {
            path.append(route)
        }
    }
}
