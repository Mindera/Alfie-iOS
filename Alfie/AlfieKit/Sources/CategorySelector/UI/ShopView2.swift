import Combine
import Core
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif
import Web

struct ShopView2<
    CategoriesViewModel: CategoriesViewModelProtocol,
    BrandsViewModel: BrandsViewModelProtocol,
    ServicesViewModel: WebViewModelProtocol2
>: View {
    private let isRoot: Bool
    private let isWishlistEnabled: Bool
    @ViewBuilder private let categoriesView: CategoriesView2<CategoriesViewModel>
    @ViewBuilder private let brandsView: BrandsView2<BrandsViewModel>
    @ViewBuilder private let servicesView: WebView2<ServicesViewModel>?
    private let categoriesViewModel: CategoriesViewModel
    private let navigate: (CategorySelectorRoute) -> Void

    private var segments: [Segment] = []
    @State private var selectedSegment: Segment
    @State private var activeTab: ShopViewTab2
    @State private var isVisible = false

    init(
        isRoot: Bool,
        isWishlistEnabled: Bool,
        categoriesViewModel: CategoriesViewModel,
        brandsViewModel: BrandsViewModel,
        servicesViewModel: ServicesViewModel?,
        initialTab tab: ShopViewTab2 = .categories,
        navigate: @escaping (CategorySelectorRoute) -> Void
    ) {
        self.isRoot = isRoot
        self.isWishlistEnabled = isWishlistEnabled
        self.categoriesViewModel = categoriesViewModel
        self.categoriesView = CategoriesView2(viewModel: categoriesViewModel)
        self.brandsView = BrandsView2(viewModel: brandsViewModel)
        self.servicesView = servicesViewModel.flatMap { WebView2(viewModel: $0) }
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
                    activeTab = newValue.object as? ShopViewTab2 ?? .categories
                }

            TabView(selection: $activeTab) {
                categoriesView
                    .simultaneousGesture(DragGesture())
                    .tag(ShopViewTab2.categories)

                brandsView
                    .gesture(DragGesture())
                    .tag(ShopViewTab2.brands)
                    .accessibilityIdentifier(AccessibilityId.brandsPage)

                if let servicesView {
                    servicesView
                        .gesture(DragGesture())
                        .tag(ShopViewTab2.services)
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
        // TBD: See if there is the need to support something like this
//        .onReceive(tabCoordinator.shopViewTabUpdatePublisher.receive(on: DispatchQueue.main)) { tab in
//            guard let tab else {
//                return
//            }
//            switchTabIfNecessary(tab, withAnimation: false)
//        }
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

    private func switchTabIfNecessary(_ tab: ShopViewTab2, withAnimation: Bool) {
        guard
            let index = ShopViewTab2.allCases.firstIndex(of: tab),
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

extension ShopView2 {
    var availableTabs: [ShopViewTab2] {
        ShopViewTab2.allCases.compactMap { tab in
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

extension ShopViewTab2 {
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
    ShopView2(
        isRoot: true,
        isWishlistEnabled: true,
        categoriesViewModel: MockCategoriesViewModel(
            state: .success(.init(categories: [])),
            categories: NavigationItem.fixtures
        ),
        brandsViewModel: MockBrandsViewModel(),
        servicesViewModel: WebViewModel2(
            url: URL(string: "https://www.alfieproj.com/services/store-services"),
            dependencies: WebDependencyContainer2(
                deepLinkService: MockDeepLinkService(),
                webViewConfigurationService: MockWebViewConfigurationService(),
                webUrlProvider: MockWebUrlProvider()
            )
        )
    ) { _ in }
}
#endif
