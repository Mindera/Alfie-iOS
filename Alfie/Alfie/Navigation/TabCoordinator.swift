import Combine
import Common
import Foundation
import Models
import Navigation
import StyleGuide

// MARK: - TabCoordinatorProtocol

protocol TabCoordinatorProtocol {
    var tabs: [TabScreen] { get }
    var activeTab: TabScreen { get }
    var navigationAvailability: AnyPublisher<Bool, Never> { get }
    var isReadyForNavigation: Bool { get }

    func navigate(to screen: Screen)
}

// MARK: - TabCoordinator

final class TabCoordinator: TabCoordinatorProtocol, ObservableObject {
    typealias Tab = TabScreen
    typealias CoordinatedTabView = CoordinatedView<Coordinator, ViewFactory>

    @Published var tabs: [Tab]
    @Published var activeTab: Tab
    @Published private(set) var isReadyForNavigation = false
    @Published private(set) var shouldShowTabBar = true
    private var activeViewFullScreenOverlayCancellable: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    private var coordinatedViews: [Tab: CoordinatedTabView]
    private let shopViewTabUpdateSubject: CurrentValueSubject<ShopViewTab?, Never> = .init(nil)

    var navigationAvailability: AnyPublisher<Bool, Never> { $isReadyForNavigation.eraseToAnyPublisher() }
    // Specific view updates
    let shopViewTabUpdatePublisher: AnyPublisher<ShopViewTab?, Never>

    init(tabs: [Tab],
         activeTab: Tab,
         serviceProvider: ServiceProviderProtocol) {
        self.tabs = tabs
        self.activeTab = activeTab
        self.shopViewTabUpdatePublisher = shopViewTabUpdateSubject.eraseToAnyPublisher()
        coordinatedViews = Self.buildTabViews(from: tabs, with: serviceProvider)

        setupSubscriptions()
        setupFullScreenOverlayObserver(for: activeTab)
    }

    private func setupSubscriptions() {
        $activeTab.sink { [weak self] tab in
            guard let self else {
                return
            }
            self.shouldShowTabBar = true
            self.setupFullScreenOverlayObserver(for: tab)
        }
        .store(in: &subscriptions)
    }

    private func setupFullScreenOverlayObserver(for tab: Tab) {
        activeViewFullScreenOverlayCancellable = coordinatedViews[tab]?.navigationAdapter
            .$isPresentingFullScreenOverlay
            .map { !$0 }
            .assignWeakly(to: \.shouldShowTabBar, on: self)
    }

    func removeCoordinatedViews() {
        coordinatedViews = [:]
    }

    // MARK: - Internal Methods

    func enableNavigation(isActive: Bool) {
        isReadyForNavigation = isActive
    }

    func navigate(to screen: Screen) {
        guard let coordinator = activeTabCoordinator() else {
            return
        }
        coordinator.closeDebugMenu()
        switch screen {
            case .tab(let tab):
                updateActiveTab(tab)
            case .webView(let url, let title):
                coordinator.open(url: url, title: title)
            case .webFeature(let feature):
                coordinator.open(webFeature: feature)
            case .forceAppUpdate:
                coordinator.openForceAppUpdate()
            case .account:
                coordinator.openAccount()
            case .wishlist:
                coordinator.openWishlist()
            case .productListing(let configuration):
                coordinator.openProductListing(configuration: configuration)
            case .search,
                 .recentSearches,
                 .debugMenu:
                break
            case .productDetails(let type):
                switch type {
                    case .id(let id):
                        coordinator.openDetails(for: id)
                    case .product(let product):
                        coordinator.openDetails(for: product)
                }
            case .categoryList(let categories, let title):
                coordinator.openCategories(categories, title: title)
        }
    }

    func popToRoot() {
        guard let coordinator = activeTabCoordinator() else {
            return
        }
        coordinator.popToRoot()
    }

    func view(for tab: Tab) -> CoordinatedTabView? {
        coordinatedViews[tab]
    }

    // MARK: - Private Methods

    private static func buildTabViews(from tabs: [Tab], with serviceProvider: ServiceProviderProtocol) -> [Tab: CoordinatedTabView] {
        let viewFactory = ViewFactory(serviceProvider: serviceProvider)
        return tabs.reduce(into: [Tab: CoordinatedTabView]()) { dict, tab in
            dict[tab] = .init(rootScreen: tab.correspondingScreen, viewFactory: viewFactory)
        }
    }

    private func activeTabCoordinator() -> Coordinator? {
        view(for: activeTab)?.coordinator
    }

    private func updateActiveTab(_ tab: Tab) {
        switch tab {
            case .shop(let shopTab):
                activeTab = .shop()
                if let shopTab {
                    shopViewTabUpdateSubject.send(shopTab)
                }
            default:
                activeTab = tab
        }
    }
}

extension TabScreen {
    var title: LocalizedStringResource {
        switch self {
            case .home:
                LocalizableGeneral.home
            case .shop:
                LocalizableGeneral.shop
            case .wishlist:
                LocalizableGeneral.wishlist
            case .bag:
                LocalizableGeneral.bag
        }
    }

    var icon: Icon {
        switch self {
            case .home:
                .home
            case .shop:
                .store
            case .bag:
                .bag
            case .wishlist:
                .heart
        }
    }

    var accessibilityId: String {
        switch self {
            case .home:
                "home-tab"
            case .shop:
                "shop-tab"
            case .bag:
                "bag-tab"
            case .wishlist:
                "wishlist-tab"
        }
    }
}
