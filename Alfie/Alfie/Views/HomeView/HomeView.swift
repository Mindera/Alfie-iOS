import Models
import StyleGuide
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinador: Coordinator
    private let viewFactory: ViewFactory?
    @State private var showSearchBar = true
    @State private var isUserLogged = false
    @Namespace private var animation

    init(viewFactory: ViewFactory? = nil) {
        self.viewFactory = viewFactory
    }

    var body: some View {
        VStack {
            if !coordinador.navigationAdapter.isPresentingFullScreenOverlay {
                ThemedSearchBarView(
                    searchText: .constant(""),
                    placeholder: L10n.$homeSearchBarPlaceholder,
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
            Text.build(theme.font.header.h3(L10n.homeTitle))
            ThemedButton(text: isUserLogged ? L10n.$homeSignOutButtonCTA : L10n.$homeSignInButtonCTA) {
                isUserLogged.toggle()
            }
            Spacer()
        }
        .withToolbar(
            for: .tab(
                .home(isUserLogged ? .loggedIn(username: "Alfie", memberSince: 2024) : .loggedOut)
            )
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

#Preview {
    HomeView()
        .environmentObject(Coordinator())
}
