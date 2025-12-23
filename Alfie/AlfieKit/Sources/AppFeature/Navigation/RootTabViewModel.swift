import Bag
import CategorySelector
import Combine
import Foundation
import Home
import Model
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

    public let bagFlowViewModel: BagFlowVM
    public let categorySelectorFlowViewModel: CategorySelectorVM
    public let homeFlowViewModel: HomeFlowVM
    public let wishlistFlowViewModel: WishlistFlowVM
    @Published public private(set) var overlayView: AnyView?
    @Published public var isOverlayVisible = false
    @Published public var isReadyForNavigation = false
    private var subscriptions = Set<AnyCancellable>()

    public init(
        tabs: [Model.Tab],
        initialTab: Model.Tab,
        serviceProvider: ServiceProviderProtocol,
        bagFlowViewModel: BagFlowVM,
        categorySelectorFlowViewModel: CategorySelectorVM,
        homeFlowViewModel: HomeFlowVM,
        wishlistFlowViewModel: WishlistFlowVM
    ) {
        guard tabs.contains(initialTab) else {
            fatalError("Initial tab \(initialTab) does not exist in the list of tabs \(tabs)")
        }

        self.tabs = tabs
        self.selectedTab = initialTab
        self.serviceProvider = serviceProvider
        self.bagFlowViewModel = bagFlowViewModel
        self.categorySelectorFlowViewModel = categorySelectorFlowViewModel
        self.homeFlowViewModel = homeFlowViewModel
        self.wishlistFlowViewModel = wishlistFlowViewModel

        setupBindings()
    }

    public func popToRoot(in tab: Model.Tab) {
        switch tab {
        case .bag:
            bagFlowViewModel.popToRoot()

        case .home:
            homeFlowViewModel.popToRoot()

        case .shop:
            categorySelectorFlowViewModel.popToRoot()

        case .wishlist:
            wishlistFlowViewModel.popToRoot()
        }
    }

    public func navigate(_ route: TabRoute) {
        guard tabs.contains(route.tab) else { return }
        selectedTab = route.tab
        overlayView = nil

        switch route {
        case .bag(let bagRoute):
            bagFlowViewModel.navigate(bagRoute)

        case .home(let homeRoute):
            homeFlowViewModel.navigate(homeRoute)

        case .shop(let categorySelectorRoute):
            categorySelectorFlowViewModel.navigate(categorySelectorRoute)

        case .wishlist(let wishlistRoute):
            wishlistFlowViewModel.navigate(wishlistRoute)
        }
    }

    private func setupBindings() {
        homeFlowViewModel.overlayViewPublisher
            .assignWeakly(to: \.overlayView, on: self)
            .store(in: &subscriptions)

        categorySelectorFlowViewModel.overlayViewPublisher
            .assignWeakly(to: \.overlayView, on: self)
            .store(in: &subscriptions)

        $overlayView
            .map { $0 != nil }
            .assignWeakly(to: \.isOverlayVisible, on: self)
            .store(in: &subscriptions)

        $isReadyForNavigation
            .sink { [weak self] in self?.serviceProvider.deepLinkService.updateAvailabilityOfHandlers(to: $0) }
            .store(in: &subscriptions)
    }
}
