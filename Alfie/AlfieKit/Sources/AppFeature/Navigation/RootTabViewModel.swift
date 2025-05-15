import Bag
import CategorySelector
import Combine
import Foundation
import Home
import Model
import SwiftUI
import Wishlist

public final class RootTabViewModel: ObservableObject {
    let tabs: [Model.Tab]
    @Published var selectedTab: Model.Tab
    private let serviceProvider: ServiceProviderProtocol

    let bagFlowViewModel: BagFlowViewModel
    let categorySelectorFlowViewModel: CategorySelectorFlowViewModel
    let homeFlowViewModel: HomeFlowViewModel
    let wishlistFlowViewModel: WishlistFlowViewModel
    @Published private(set) var overlayView: AnyView?
    @Published var isOverlayVisible = false
    @Published public var isReadyForNavigation = false
    private var subscriptions = Set<AnyCancellable>()

    public init(
        tabs: [Model.Tab],
        initialTab: Model.Tab,
        serviceProvider: ServiceProviderProtocol
    ) {
        guard tabs.contains(initialTab) else {
            fatalError("Initial tab \(initialTab) does not exist in the list of tabs \(tabs)")
        }

        self.tabs = tabs
        self.selectedTab = initialTab
        self.serviceProvider = serviceProvider

        self.bagFlowViewModel = BagFlowViewModel(
            serviceProvider: serviceProvider
        )
        self.categorySelectorFlowViewModel = CategorySelectorFlowViewModel(
            serviceProvider: serviceProvider
        )
        self.homeFlowViewModel = HomeFlowViewModel(
            serviceProvider: serviceProvider
        )
        self.wishlistFlowViewModel = WishlistFlowViewModel(
            serviceProvider: serviceProvider
        )

        setupBindings()
    }

    func popToRoot(in tab: Model.Tab) {
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

    func navigate(_ route: TabRoute) {
        guard tabs.contains(route.tab) else { return }
        selectedTab = route.tab
        overlayView = nil

        switch route {
        case .bag(let bagRoute):
            if case .bag = bagRoute {
                popToRoot(in: .bag)
            } else {
                bagFlowViewModel.navigate(bagRoute)
            }

        case .home(let homeRoute):
            if case .home = homeRoute {
                popToRoot(in: .home)
            } else {
                homeFlowViewModel.navigate(homeRoute)
            }

        case .shop(let categorySelectorRoute):
            switch categorySelectorRoute {
            case .categorySelector(let shopViewTab):
                popToRoot(in: .shop)
                categorySelectorFlowViewModel.activeShopTab = shopViewTab

            default:
                categorySelectorFlowViewModel.navigate(categorySelectorRoute)
            }

        case .wishlist(let wishlistRoute):
            if case .wishlist = wishlistRoute {
                popToRoot(in: .wishlist)
            } else {
                wishlistFlowViewModel.navigate(wishlistRoute)
            }
        }
    }

    private func setupBindings() {
        homeFlowViewModel.$overlayView
            .assignWeakly(to: \.overlayView, on: self)
            .store(in: &subscriptions)

        categorySelectorFlowViewModel.$overlayView
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
