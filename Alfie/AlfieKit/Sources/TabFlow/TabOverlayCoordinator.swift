import Combine
import Model
import ProductDetails
import ProductListing
import Scanner
import Search
import SwiftUI
import Web

/// The search and scan overlays a tab presents, and the search flow behind them.
///
/// Shared by every tab that offers them rather than reimplemented per tab, so a second tab is one
/// coordinator, not another copy of the state, the bindings and the search-intent destinations.
public final class TabOverlayCoordinator {
    private enum Overlay {
        case search
        case scanner
    }

    private let dependencies: TabOverlayDependencyContainer
    @Published private var tabOverlay: TabOverlay?
    public var overlayPublisher: AnyPublisher<TabOverlay?, Never> { $tabOverlay.eraseToAnyPublisher() }

    private lazy var searchFlowViewModel: SearchFlowViewModel = {
        SearchFlowViewModel(
            dependencies: dependencies.search,
            intentViewBuilder: { [weak self] in
                self?.searchIntentViewBuilder(for: $0) ?? AnyView(Text("Something went wrong"))
            },
            closeSearchAction: { [weak self] in self?.dismiss() }
        )
    }()

    public init(dependencies: TabOverlayDependencyContainer) {
        self.dependencies = dependencies
    }

    /// The one way back to search, shared by every screen that offers it — so a test driving any of
    /// them covers the wiring for all, including the builders reached only through `SearchFlowViewModel`.
    public var showSearch: () -> Void {
        { [weak self] in self?.presentSearch() }
    }

    public var showScanner: () -> Void {
        { [weak self] in self?.presentScanner() }
    }

    public func presentSearch() {
        present(.search)
    }

    public func presentScanner() {
        present(.scanner)
    }

    public func dismiss() {
        present(nil)
    }

    /// One value in, one overlay out, so a second overlay cannot open behind the first and
    /// `tabOverlay` keeps a single writer.
    private func present(_ overlay: Overlay?) {
        switch overlay {
        case .search:
            tabOverlay = TabOverlay(
                view: AnyView(SearchFlowView(viewModel: searchFlowViewModel)),
                hidesTabBar: false
            )

        case .scanner:
            tabOverlay = TabOverlay(
                view: AnyView(ScannerView(viewModel: makeScannerViewModel())),
                hidesTabBar: true
            )

        case nil:
            tabOverlay = nil
        }
    }

    /// Closing clears the overlay as well as dismissing the screen, so the flow does not go on
    /// believing the scanner is up and refuse to present it a second time.
    private func makeScannerViewModel() -> ScannerViewModel {
        ScannerPresentation.makeViewModel(
            dependencies: dependencies.scanner,
            source: .searchBar,
            close: { [weak self] in self?.dismiss() }
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

    private func makeProductListingViewModelForSearch(
        searchTerm: String?,
        category: String?
    ) -> some ProductListingViewModelProtocol {
        ProductListingViewModel(
            dependencies: dependencies.productListing,
            category: category,
            searchText: searchTerm,
            urlQueryParameters: nil,
            mode: .searchResults,
            navigate: { [weak self] in self?.searchFlowViewModel.navigate(.searchIntent(SearchIntent(route: $0))) },
            showSearch: showSearch
        )
    }

    private func makeProductDetailsViewModelForSearch(
        configuration: ProductDetailsConfiguration
    ) -> some ProductDetailsViewModelProtocol {
        ProductDetailsViewModel(
            configuration: configuration,
            dependencies: dependencies.productDetails,
            goBackAction: { [weak self] in self?.searchFlowViewModel.pop() },
            openWebfeatureAction: { [weak self] in self?.searchFlowViewModel.navigate(.searchIntent(.webFeature($0))) },
            openProductAction: { [weak self] in self?.searchFlowViewModel.navigate(.searchIntent(.productDetails($0))) }
        )
    }

    private func makeWebViewModelForSearch(feature: WebFeature) -> some WebViewModelProtocol {
        WebViewModel(webFeature: feature, dependencies: dependencies.web)
    }
}
