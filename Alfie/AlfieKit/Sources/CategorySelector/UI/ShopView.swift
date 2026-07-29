import Combine
import Core
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif
import Web

struct ShopView<
    CategoriesViewModel: CategoriesViewModelProtocol,
    ServicesViewModel: WebViewModelProtocol
>: View {
    private let isRoot: Bool
    private let isWishlistEnabled: Bool
    @ViewBuilder private let categoriesView: CategoriesView<CategoriesViewModel>
    private let navigate: (CategorySelectorRoute) -> Void

    init(
        isRoot: Bool,
        isWishlistEnabled: Bool,
        categoriesViewModel: CategoriesViewModel,
        servicesViewModel: ServicesViewModel?,
        initialTab tab: ShopViewTab = .categories,
        activeShopTabPublisher: AnyPublisher<ShopViewTab, Never>,
        navigate: @escaping (CategorySelectorRoute) -> Void
    ) {
        self.isRoot = isRoot
        self.isWishlistEnabled = isWishlistEnabled
        self.categoriesView = CategoriesView(viewModel: categoriesViewModel)
        self.navigate = navigate
        // Segmented tab control removed per design — the Store shows the categories menu directly.
        // `servicesViewModel` / `activeShopTabPublisher` kept in the signature but dormant, for reversibility.
    }

    var body: some View {
        categoriesView
            .toolbarView(
                isRoot: isRoot,
                isWishlistEnabled: isWishlistEnabled,
                openWishlistAction: { navigate(.wishlist(.wishlist)) },
                myAccountAction: { navigate(.myAccount(.myAccount)) }
            )
    }
}

// MARK: Preview

#if DEBUG
#Preview {
    ShopView(
        isRoot: true,
        isWishlistEnabled: true,
        categoriesViewModel: MockCategoriesViewModel(
            state: .success(.init(categories: [])),
            categories: NavigationItem.fixtures
        ),
        servicesViewModel: WebViewModel(
            url: URL(string: "https://www.alfieproj.com/services/store-services"),
            dependencies: WebDependencyContainer(
                deepLinkService: MockDeepLinkService(),
                webViewConfigurationService: MockWebViewConfigurationService(),
                webUrlProvider: MockWebUrlProvider()
            )
        ),
        activeShopTabPublisher: Empty<ShopViewTab, Never>().eraseToAnyPublisher()
    ) { _ in }
}
#endif
