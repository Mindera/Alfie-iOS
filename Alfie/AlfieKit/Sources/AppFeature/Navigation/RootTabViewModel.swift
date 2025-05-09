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

    let homeFlowViewModel: HomeFlowViewModel
    let wishlistFlowViewModel: WishlistFlowViewModel
    @Published var overlayView: AnyView?
    @Published var isOverlayVisible = false
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
            print("TODO")

        case .home:
            homeFlowViewModel.popToRoot()

        case .shop:
            print("TODO")

        case .wishlist:
            wishlistFlowViewModel.popToRoot()
        }
    }

    private func setupBindings() {
        homeFlowViewModel.$overlayView
            .assignWeakly(to: \.overlayView, on: self)
            .store(in: &subscriptions)

        $overlayView
            .map { $0 != nil }
            .assignWeakly(to: \.isOverlayVisible, on: self)
            .store(in: &subscriptions)
    }
}
