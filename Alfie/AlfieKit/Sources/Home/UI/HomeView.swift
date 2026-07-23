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
        VStack(spacing: theme.spacing.space0) {
            ThemedSearchBarView(
                searchText: .constant(""),
                placeholder: L10n.Home.SearchBar.placeholder,
                theme: .soft,
                dismissConfiguration: .init(type: .back, accessibilityId: AccessibilityID.Home.searchBackButton),
                inputAccessibilityId: AccessibilityID.Home.searchInput
            )
            .matchedGeometryEffect(id: Constants.searchBarGeometryID, in: animation)
            .disabled(true)
            .onTapGesture {
                viewModel.didTapSearch()
            }
            .padding(.horizontal, theme.spacing.space200)
            .padding(.top, theme.spacing.space100)
            .padding(.bottom, theme.spacing.space200)

            ScrollView {
                VStack(spacing: theme.spacing.space0) {
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
