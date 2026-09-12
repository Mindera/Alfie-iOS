import Combine
import Core
import Model
import MyAccount
import ProductDetails
import ProductListing
import Scanner
import Search
import SwiftUI
import Web
import Wishlist

public final class HomeFlowViewModel: HomeFlowViewModelProtocol {
    public typealias Route = HomeRoute
    @Published public var path = NavigationPath()
    private let dependencies: HomeFlowDependencyContainer
    /// Which screen, if any, is covering the tab. One value rather than a flag per screen, so a
    /// second overlay cannot open behind the first and so `overlayView` has a single writer.
    private enum Overlay {
        case search
        case scanner
    }

    @Published private var overlay: Overlay?
    @Published private var overlayView: AnyView?
    public var overlayViewPublisher: AnyPublisher<AnyView?, Never> { $overlayView.eraseToAnyPublisher() }
    private var subscriptions = Set<AnyCancellable>()

    private lazy var searchFlowViewModel: SearchFlowViewModel = {
        SearchFlowViewModel(
            dependencies: dependencies.searchDependencyContainer,
            intentViewBuilder: { [weak self] in
                self?.searchIntentViewBuilder(for: $0) ?? AnyView(Text("Something went wrong"))
            },
            closeSearchAction: { [weak self] in self?.overlay = nil }
        )
    }()

    public init(dependencies: HomeFlowDependencyContainer) {
        self.dependencies = dependencies
        setupBindings()
    }

    private func setupBindings() {
        $overlay
            .sink { [weak self] overlay in
                guard let self else { return }

                switch overlay {
                case .search:
                    overlayView = AnyView(SearchFlowView(viewModel: searchFlowViewModel))

                case .scanner:
                    overlayView = AnyView(ScannerView(viewModel: makeScannerViewModel()))

                case nil:
                    overlayView = nil
                }
            }
            .store(in: &subscriptions)
    }

    /// Closing clears the overlay as well as dismissing the screen, so the flow does not go on
    /// believing the scanner is up and refuse to present it a second time. The rest of the wiring is
    /// the same on every tab — see ``ScannerPresentation``.
    private func makeScannerViewModel() -> ScannerViewModel {
        ScannerPresentation.makeViewModel(
            dependencies: dependencies.scannerDependencyContainer,
            source: .searchBar,
            close: { [weak self] in self?.overlay = nil }
        )
    }

    // MARK: - View Models for HomeRoute

    public func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            dependencies: dependencies.homeDependencyContainer,
            navigate: { [weak self] route in self?.navigate(route) },
            showSearch: { [weak self] in self?.overlay = .search },
            showScanner: { [weak self] in self?.overlay = .scanner }
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
            showSearch: { [weak self] in self?.overlay = .search }
        )
    }

    public func makeProductDetailsViewModel(configuration: ProductDetailsConfiguration) -> ProductDetailsViewModel {
        ProductDetailsViewModel(
            configuration: configuration,
            dependencies: dependencies.productDetailsDependencyContainer,
            goBackAction: { [weak self] in self?.pop() },
            openWebfeatureAction: { [weak self] in self?.navigate(.productListing(.productDetails(.webFeature($0)))) }
        )
    }

    public func makeWebViewModel(feature: WebFeature) -> WebViewModel {
        WebViewModel(
            webFeature: feature,
            dependencies: dependencies.webDependencyContainer
        )
    }

    // MARK: - View Models for SearchIntent

    private func searchIntentViewBuilder(for intent: SearchIntent) -> AnyView {
        switch intent {
        case .productListing(let searchTerm, let category):
            return AnyView(
                ProductListingView(
                    viewModel: makeProductListingViewModelForSearch(searchTerm: searchTerm, category: category)
                )
            )

        case .productDetails(let productID, let product):
            let configuration: ProductDetailsConfiguration
            if let product {
                configuration = .product(product)
            } else {
                configuration = .id(productID)
            }

            return AnyView(
                ProductDetailsView(
                    viewModel: makeProductDetailsViewModelForSearch(configuration: configuration)
                )
            )

        case .webFeature(let feature):
            return AnyView(
                WebView(viewModel: makeWebViewModelForSearch(feature: feature))
                    .toolbarView(title: feature.title)
            )
        }
    }

    /// Internal rather than private so a test can reach it: it is otherwise only called from inside
    /// a closure handed to `SearchFlowViewModel`, which no unit test drives.
    func makeProductListingViewModelForSearch(
        searchTerm: String?,
        category: String?
    ) -> some ProductListingViewModelProtocol {
        let configuration = ProductListingScreenConfiguration(
            category: category,
            searchText: searchTerm,
            urlQueryParameters: nil,
            mode: .searchResults
        )

        return ProductListingViewModel(
            dependencies: dependencies.productListingDependencyContainer,
            category: configuration.category,
            searchText: configuration.searchText,
            urlQueryParameters: configuration.urlQueryParameters,
            mode: configuration.mode,
            navigate: { [weak self] route in
                switch route {
                case .productDetails(let productDetailsRoute):
                    let productID: String
                    let product: Product?

                    switch productDetailsRoute {
                    case .productDetails(let configuration):
                        switch configuration {
                        case .id(let configurationProductID), .deepLink(let configurationProductID):
                            productID = configurationProductID
                            product = nil

                        case .product(let configurationProduct):
                            productID = configurationProduct.id
                            product = configurationProduct

                        case .selectedProduct(let selectedProduct):
                            productID = selectedProduct.product.id
                            product = selectedProduct.product
                        }

                        self?.searchFlowViewModel.navigate(
                            .searchIntent(.productDetails(productID: productID, product: product))
                        )

                    case .webFeature(let feature):
                        self?.searchFlowViewModel.navigate(.searchIntent(.webFeature(feature)))
                    }

                case .productListing(let configuration):
                    self?.searchFlowViewModel.navigate(
                        .searchIntent(
                            .productListing(searchTerm: configuration.searchText, category: configuration.category)
                        )
                    )
                }
            },
            showSearch: { [weak self] in self?.overlay = .search }
        )
    }

    private func makeProductDetailsViewModelForSearch(
        configuration: ProductDetailsConfiguration
    ) -> some ProductDetailsViewModelProtocol {
        ProductDetailsViewModel(
            configuration: configuration,
            dependencies: dependencies.productDetailsDependencyContainer,
            goBackAction: { [weak self] in self?.searchFlowViewModel.pop() },
            openWebfeatureAction: { [weak self] in self?.searchFlowViewModel.navigate(.searchIntent(.webFeature($0))) }
        )
    }

    private func makeWebViewModelForSearch(feature: WebFeature) -> some WebViewModelProtocol {
        WebViewModel(webFeature: feature, dependencies: dependencies.webDependencyContainer)
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
