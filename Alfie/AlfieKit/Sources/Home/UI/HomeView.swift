import AccessibilityIdentifiers
import Core
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct HomeView<ViewModel: HomeViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @Namespace private var animation

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: theme.sizing.spacingSpacingNone) {
            SearchBarEntryButton(
                placeholder: L10n.Home.SearchBar.placeholder,
                accessibilityIdentifier: AccessibilityID.Home.searchInput,
                scan: .init(
                    accessibilityIdentifier: AccessibilityID.Home.scanButton,
                    action: viewModel.didTapScan
                ),
                action: viewModel.didTapSearch
            )
            .matchedGeometryEffect(id: Constants.searchBarGeometryID, in: animation)
            .padding(.horizontal, theme.sizing.spacingSpacingMd)
            .padding(.top, theme.sizing.spacingSpacingXs)
            .padding(.bottom, theme.sizing.spacingSpacingMd)

            ScrollView {
                VStack(spacing: theme.sizing.spacingSpacingNone) {
                    HomeHeroCarouselView(banners: viewModel.heroBanners)
                }
            }
        }
        .toolbarView()
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .fullScreenCover(
            isPresented: Binding(
                get: { viewModel.fullScreenCover != nil },
                set: { if !$0 { viewModel.fullScreenCover = nil } }
            )
        ) {
            viewModel.fullScreenCover
        }
    }
}

private enum Constants {
    static let searchBarGeometryID = "SearchBar"
}

#if DEBUG
#Preview {
    HomeView(viewModel: MockHomeViewModel())
}
#endif
