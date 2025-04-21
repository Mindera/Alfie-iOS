import Core
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct HomeView<ViewModel: HomeViewModelProtocol>: View {
    @EnvironmentObject var coordinador: Coordinator
    @StateObject private var viewModel: ViewModel
    @State private var showSearchBar = true
    @Namespace private var animation

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            if !coordinador.navigationAdapter.isPresentingFullScreenOverlay {
                ThemedSearchBarView(
                    searchText: .constant(""),
                    placeholder: L10n.Home.SearchBar.placeholder,
                    theme: .soft,
                    dismissConfiguration: .init(type: .back, accessibilityId: Constants.cancelAccessibilityId),
                    inputAccessibilityId: Constants.searchAccessibility
                )
                .matchedGeometryEffect(id: Constants.searchBarGeometryID, in: animation)
                .disabled(true)
                .onTapGesture {
                    coordinador.navigationAdapter.presentFullscreenOverlay(
                        with: .search(
                            transition: .matchedGeometryEffect(
                                id: Constants.searchBarGeometryID,
                                namespace: animation
                            )
                        )
                    )
                }
                .padding(.horizontal, Spacing.space200)
                .padding(.vertical, Spacing.space100)
            }
            Spacer()
            Icon.home.image
                .resizable()
                .scaledToFit()
                .frame(width: 75)
            Text.build(theme.font.header.h3(viewModel.homeTitle))
            ThemedButton(text: viewModel.signInButtonText) {
                viewModel.didTapSignInButton()
            }
            Spacer()
        }
        .toolbarView(username: viewModel.username, memberSince: viewModel.memberSince)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

private extension View {
    func toolbarView(username: String?, memberSince: Int?) -> some View {
        if let username, let memberSince {
            withToolbar(for: .tab(.home(.loggedIn(username: username, memberSince: memberSince))))
        } else {
            withToolbar(for: .tab(.home(.loggedOut)))
        }
    }
}

private enum Constants {
    static let searchBarGeometryID = "SearchBar"
    static let searchAccessibility = "search-input"
    static let cancelAccessibilityId = "back-btn"
}

#if DEBUG
#Preview {
    HomeView(viewModel: MockHomeViewModel())
        .environmentObject(Coordinator())
}
#endif
