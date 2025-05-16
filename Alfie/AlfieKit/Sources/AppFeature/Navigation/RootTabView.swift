import Bag
import CategorySelector
import Foundation
import Home
import Model
import Search
import SharedUI
import SwiftUI
import Wishlist

public struct RootTabView<ViewModel: RootTabViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @State private var badgeNumbers: [Model.Tab: Int?] = [:]
    @State private var tabBarSize: CGSize = .zero

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $viewModel.selectedTab) {
                ForEach(viewModel.tabs, id: \.self) { tab in
                    switch tab {
                    case .bag:
                        BagFlowView(viewModel: viewModel.bagFlowViewModel)
                            .environment(\.tabBarSize, tabBarSize)

                    case .home:
                        HomeFlowView(viewModel: viewModel.homeFlowViewModel)
                            .environment(\.tabBarSize, tabBarSize)

                    case .shop:
                        CategorySelectorFlowView(viewModel: viewModel.categorySelectorFlowViewModel)
                            .environment(\.tabBarSize, tabBarSize)

                    case .wishlist:
                        WishlistFlowView(viewModel: viewModel.wishlistFlowViewModel)
                            .environment(\.tabBarSize, tabBarSize)
                    }
                }
            }
            .accentColor(Colors.primary.black)
            .padding(.bottom, Spacing.space150)

            if !viewModel.isOverlayVisible {
                CustomTabBarView(
                    tabs: viewModel.tabs,
                    currentTab: $viewModel.selectedTab
                ) {
                    viewModel.popToRoot(in: $0)
                }
                .writingSize(
                    to: .init(
                        get: { .zero },
                        set: { size in tabBarSize = size }
                    )
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }

            if let overlay = viewModel.overlayView {
                overlay
                    .zIndex(2)
            }
        }
        .ignoresSafeArea(.keyboard)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isOverlayVisible)
        .onAppear {
            viewModel.isReadyForNavigation = true
        }
    }
}
