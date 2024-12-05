import Models
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

struct HomeView<ViewModel: HomeViewModelProtocol>: View {
    @EnvironmentObject var coordinador: Coordinator
    private let viewFactory: ViewFactory?
    private let viewModel: ViewModel
    @State private var showSearchBar = true
    @Namespace private var animation
    @State private var loggedInCheckboxState = CheckboxState.selected

    init(viewFactory: ViewFactory? = nil, viewModel: ViewModel) {
        self.viewFactory = viewFactory
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if !coordinador.navigationAdapter.isPresentingFullScreenOverlay {
                ThemedSearchBarView(
                    searchText: .constant(""),
                    placeholder: LocalizableHome.$searchBarPlaceholder,
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
            Text.build(theme.font.header.h3(LocalizableHome.title))
            Checkbox(state: $loggedInCheckboxState, text: "Logged In")
            Spacer()
        }
        .withToolbar(
            for: .tab(
                .home(loggedInCheckboxState.isSelected ? .loggedIn(username: "Alfie", memberSince: 2024) : .loggedOut)
            ),
            viewModel: viewModel.toolbarModifierViewModel
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
        // TODO: Remove debug menu for production releases
        .fullScreenCover(isPresented: $coordinador.isPresentingDebugMenu) {
            viewFactory?.view(for: .debugMenu)
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
