import Bag
import CategorySelector
import Combine
import CombineSchedulers
import Foundation
import Home
import Model
import MyAccount
import SwiftUI
import Wishlist

public final class RootTabViewModel<
    BagFlowVM: BagFlowViewModelProtocol,
    CategorySelectorVM: CategorySelectorFlowViewModelProtocol,
    HomeFlowVM: HomeFlowViewModelProtocol,
    WishlistFlowVM: WishlistFlowViewModelProtocol
>: RootTabViewModelProtocol
where BagFlowVM.Route == BagRoute,
CategorySelectorVM.Route == CategorySelectorRoute,
HomeFlowVM.Route == HomeRoute,
WishlistFlowVM.Route == WishlistRoute {
    public let tabs: [Model.Tab]
    @Published public var selectedTab: Model.Tab
    private let serviceProvider: ServiceProviderProtocol
    private let scheduler: AnySchedulerOf<DispatchQueue>

    public let bagFlowViewModel: BagFlowVM
    public let categorySelectorFlowViewModel: CategorySelectorVM
    public let homeFlowViewModel: HomeFlowVM
    public let wishlistFlowViewModel: WishlistFlowVM
    public let myAccountFlowViewModel: MyAccountFlowViewModel
    @Published public private(set) var overlayView: AnyView?
    @Published public private(set) var bagBadgeValue: Int?
    @Published public private(set) var isTabBarHidden = false
    @Published public var isReadyForNavigation = false
    private let closeSearch: () -> Void
    private var subscriptions = Set<AnyCancellable>()

    public init(
        tabs: [Model.Tab],
        initialTab: Model.Tab,
        serviceProvider: ServiceProviderProtocol,
        bagFlowViewModel: BagFlowVM,
        categorySelectorFlowViewModel: CategorySelectorVM,
        homeFlowViewModel: HomeFlowVM,
        wishlistFlowViewModel: WishlistFlowVM,
        myAccountFlowViewModel: MyAccountFlowViewModel,
        isSearchScreenOnTop: AnyPublisher<Bool, Never>,
        closeSearch: @escaping () -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        guard tabs.contains(initialTab) else {
            fatalError("Initial tab \(initialTab) does not exist in the list of tabs \(tabs)")
        }

        self.tabs = tabs
        self.selectedTab = initialTab
        self.serviceProvider = serviceProvider
        self.scheduler = scheduler
        self.bagFlowViewModel = bagFlowViewModel
        self.categorySelectorFlowViewModel = categorySelectorFlowViewModel
        self.homeFlowViewModel = homeFlowViewModel
        self.wishlistFlowViewModel = wishlistFlowViewModel
        self.myAccountFlowViewModel = myAccountFlowViewModel
        self.closeSearch = closeSearch

        setupBindings(isSearchScreenOnTop: isSearchScreenOnTop)
    }

    public func popToRoot(in tab: Model.Tab) {
        closeSearch()

        switch tab {
        case .bag:
            bagFlowViewModel.popToRoot()

        case .home:
            homeFlowViewModel.popToRoot()

        case .shop:
            categorySelectorFlowViewModel.popToRoot()

        case .wishlist:
            wishlistFlowViewModel.popToRoot()

        case .account:
            myAccountFlowViewModel.popToRoot()
        }
    }

    public func navigate(_ route: TabRoute) {
        guard tabs.contains(route.tab) else { return }
        selectedTab = route.tab

        switch route {
        case .bag(let bagRoute):
            bagFlowViewModel.navigate(bagRoute)

        case .home(let homeRoute):
            homeFlowViewModel.navigate(homeRoute)

        case .shop(let categorySelectorRoute):
            categorySelectorFlowViewModel.navigate(categorySelectorRoute)

        case .wishlist(let wishlistRoute):
            wishlistFlowViewModel.navigate(wishlistRoute)

        case .account(let myAccountRoute):
            myAccountFlowViewModel.navigate(myAccountRoute)
        }
    }

    private func setupBindings(isSearchScreenOnTop: AnyPublisher<Bool, Never>) {
        homeFlowViewModel.overlayViewPublisher
            .assignWeakly(to: \.overlayView, on: self)
            .store(in: &subscriptions)

        categorySelectorFlowViewModel.overlayViewPublisher
            .assignWeakly(to: \.overlayView, on: self)
            .store(in: &subscriptions)

        isSearchScreenOnTop
            .assignWeakly(to: \.isTabBarHidden, on: self)
            .store(in: &subscriptions)

        $selectedTab
            .dropFirst()
            .sink { [weak self] _ in self?.closeSearch() }
            .store(in: &subscriptions)

        // The cart service is the cart's single owner, so the badge follows every add, remove and
        // fetch it publishes without a request of its own. It emits from the service's actor, hence
        // the hop to main.
        serviceProvider.cartService.cartPublisher
            .map { BagBadge.value(for: $0) }
            .receive(on: scheduler)
            .assignWeakly(to: \.bagBadgeValue, on: self)
            .store(in: &subscriptions)

        $isReadyForNavigation
            .sink { [weak self] in self?.serviceProvider.deepLinkService.updateAvailabilityOfHandlers(to: $0) }
            .store(in: &subscriptions)
    }
}
