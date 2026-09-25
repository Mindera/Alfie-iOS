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

public final class CategorySelectorFlowViewModel: CategorySelectorFlowViewModelProtocol {
    public typealias Route = CategorySelectorRoute
    @Published public var path = NavigationPath()
    private let dependencies: CategorySelectorFlowDependencyContainer
    private let overlays: TabOverlayCoordinator
    public var overlayPublisher: AnyPublisher<TabOverlay?, Never> { overlays.overlayPublisher }

    public init(dependencies: CategorySelectorFlowDependencyContainer) {
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

    // MARK: - View Models for CategorySelectorRoute

    public func makeCategoriesViewModel() -> CategoriesViewModel {
        CategoriesViewModel(
            navigationService: dependencies.categorySelectorDependencyContainer.navigationService,
            log: dependencies.log,
            showToolbar: false
        ) { [weak self] in
            self?.navigate($0)
        }
    }

    public func makeSubCategoriesViewModel(
        subCategories: [NavigationItem],
        parent: NavigationItem
    ) -> CategoriesViewModel {
        CategoriesViewModel(
            log: dependencies.log,
            categories: subCategories,
            title: parent.title,
            showToolbar: true
        ) { [weak self] in
            self?.navigate($0)
        }
    }

    public func makeAccountViewModel() -> AccountViewModel {
        AccountViewModel(dependencies: dependencies.myAccountDependencyContainer) { [weak self] in
            self?.navigate(.myAccount($0))
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

    public func makeWebViewModel(feature: WebFeature) -> WebViewModel {
        WebViewModel(webFeature: feature, dependencies: dependencies.webDependencyContainer)
    }

    public func makeURLWebViewModel(url: URL, title: String) -> WebViewModel {
        WebViewModel(url: url, dependencies: dependencies.webDependencyContainer)
    }

    public func makeWishlistViewModel() -> WishlistViewModel {
        WishlistViewModel(
            hasNavigationSeparator: true,
            dependencies: dependencies.wishlistDependencyContainer
        ) { [weak self] in
            self?.navigate(.wishlist($0))
        }
    }

    // MARK: - View Models for MyAccountIntent

    public func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView {
        switch intent {
        case .wishlist:
            AnyView(
                WishlistView(viewModel: makeWishlistViewModel())
            )
        }
    }

    // MARK: - Search and Scan

    public func presentSearch() {
        overlays.presentSearch()
    }

    public func presentScanner() {
        overlays.presentScanner()
    }

    // MARK: - FlowViewModelProtocol

    public func navigate(_ route: CategorySelectorRoute) {
        switch route {
        case .categorySelector:
            popToRoot()

        default:
            path.append(route)
        }
    }
}
