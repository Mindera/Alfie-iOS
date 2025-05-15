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
    BrandsViewModel: BrandsViewModelProtocol,
    ServicesViewModel: WebViewModelProtocol
>: View {
    private let isRoot: Bool
    private let isWishlistEnabled: Bool
    @ViewBuilder private let categoriesView: CategoriesView<CategoriesViewModel>
    @ViewBuilder private let brandsView: BrandsView<BrandsViewModel>
    @ViewBuilder private let servicesView: WebView<ServicesViewModel>?
    private let categoriesViewModel: CategoriesViewModel
    private let navigate: (CategorySelectorRoute) -> Void

    private var segments: [Segment] = []
    @State private var selectedSegment: Segment
    @State private var activeTab: ShopViewTab
    @State private var isVisible = false
    private let activeShopTabPublisher: AnyPublisher<ShopViewTab, Never>

    init(
        isRoot: Bool,
        isWishlistEnabled: Bool,
        categoriesViewModel: CategoriesViewModel,
        brandsViewModel: BrandsViewModel,
        servicesViewModel: ServicesViewModel?,
        initialTab tab: ShopViewTab = .categories,
        activeShopTabPublisher: AnyPublisher<ShopViewTab, Never>,
        navigate: @escaping (CategorySelectorRoute) -> Void
    ) {
        self.isRoot = isRoot
        self.isWishlistEnabled = isWishlistEnabled
        self.categoriesViewModel = categoriesViewModel
        self.categoriesView = CategoriesView(viewModel: categoriesViewModel)
        self.brandsView = BrandsView(viewModel: brandsViewModel)
        self.servicesView = servicesViewModel.flatMap { WebView(viewModel: $0) }
        self.activeShopTabPublisher = activeShopTabPublisher
        self.navigate = navigate
        _selectedSegment = State(initialValue: Segment(id: tab.rawValue, title: tab.title, tab))
        _activeTab = State(initialValue: tab)

        segments = availableTabs.map { tab in
            Segment(id: tab.rawValue, title: tab.title, tab)
        }
    }

    var body: some View {
        VStack(spacing: Spacing.space0) {
            segmentedView
                .padding(Spacing.space200)
                .onChange(of: selectedSegment) { newValue in
                    activeTab = newValue.object as? ShopViewTab ?? .categories
                }

            TabView(selection: $activeTab) {
                categoriesView
                    .simultaneousGesture(DragGesture())
                    .tag(ShopViewTab.categories)

                brandsView
                    .gesture(DragGesture())
                    .tag(ShopViewTab.brands)
                    .accessibilityIdentifier(AccessibilityId.brandsPage)

                if let servicesView {
                    servicesView
                        .gesture(DragGesture())
                        .tag(ShopViewTab.services)
                        .accessibilityIdentifier(AccessibilityId.servicesPage)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .toolbarView(
            isRoot: isRoot,
            isWishlistEnabled: isWishlistEnabled,
            openWishlistAction: { navigate(.wishlist(.wishlist)) },
            myAccountAction: { navigate(.myAccount(.myAccount)) }
        )
        .onReceive(activeShopTabPublisher.receive(on: DispatchQueue.main)) { tab in
            switchTabIfNecessary(tab, withAnimation: false)
        }
        .onReceive(categoriesViewModel.openCategoryPublisher.receive(on: DispatchQueue.main)) { destination in
            // swiftlint:disable vertical_whitespace_between_cases
            switch destination {
            case .brands:
                switchTabIfNecessary(.brands, withAnimation: true)
            case .services:
                switchTabIfNecessary(.services, withAnimation: true)
            default:
                break
            }
            // swiftlint:enable vertical_whitespace_between_cases
        }
        .onChange(of: activeTab) { _ in
            hideKeyboard()
        }
    }

    private var segmentedView: some View {
        ThemedSegmentedView(segments, selection: $selectedSegment) { segment, animation, type in
            ThemedSegmentView(segment, type: type, currectSelected: $selectedSegment, animation: animation)
        }
        .frame(height: Constants.segmentedControlHeight)
    }

    private func switchTabIfNecessary(_ tab: ShopViewTab, withAnimation: Bool) {
        guard
            let index = ShopViewTab.allCases.firstIndex(of: tab),
            index < segments.count,
            selectedSegment != segments[index]
        else {
            return
        }

        if withAnimation {
            selectedSegment = segments[index]
        } else {
            runWithoutAnimation {
                selectedSegment = segments[index]
            }
        }
    }
}

// MARK: ShopViewTab Helper

extension ShopView {
    var availableTabs: [ShopViewTab] {
        ShopViewTab.allCases.compactMap { tab in
            switch tab {
            case .services:
                return servicesView != nil ? tab : nil

            case .categories:
                return tab

            case .brands:
                return tab
            }
        }
    }
}

// MARK: Localisation

extension ShopViewTab {
    // swiftlint:disable:next strict_fileprivate
    fileprivate var title: String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .categories:
            L10n.Shop.Categories.Segment.title
        case .brands:
            L10n.Shop.Brands.Segment.title
        case .services:
            L10n.Shop.Services.Segment.title
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

// MARK: - AccessibilityId

private enum AccessibilityId {
    static let brandsPage = "brands-page"
    static let servicesPage = "services-page"
    static let titleHeader = "title-header"
    static let searchBtn = "search-btn"
}

// MARK: - Constants

private enum Constants {
    static let segmentedControlHeight: CGFloat = 46
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
        brandsViewModel: MockBrandsViewModel(),
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
