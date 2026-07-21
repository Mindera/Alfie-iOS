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
        VStack(spacing: Primitives.Spacing.spacing0) {
            ThemedSearchBarView(
                searchText: .constant(""),
                placeholder: L10n.Home.SearchBar.placeholder,
                theme: .soft,
                dismissConfiguration: .init(type: .back, accessibilityId: AccessibilityID.cancelButton),
                inputAccessibilityId: AccessibilityID.searchInput
            )
            .matchedGeometryEffect(id: Constants.searchBarGeometryID, in: animation)
            .disabled(true)
            .onTapGesture {
                viewModel.didTapSearch()
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
            .padding(.vertical, Primitives.Spacing.spacing8)

            ScrollView {
                VStack(spacing: Primitives.Spacing.spacing0) {
                    HomeHeroCarouselView(banners: viewModel.heroBanners)
                }
            }
        }
        .toolbarView(
            username: viewModel.username,
            memberSince: viewModel.memberSince
        )
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

private enum AccessibilityID {
    static let searchInput = "search-input"
    static let cancelButton = "back-btn"
}

#if DEBUG
#Preview {
    HomeView(viewModel: MockHomeViewModel())
}
#endif
