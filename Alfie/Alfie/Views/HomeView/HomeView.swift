import Core
import Models
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

struct HomeView: View {
    @EnvironmentObject var coordinador: Coordinator
    private let viewFactory: ViewFactory?
    @State private var showSearchBar = true
    @State private var isUserLogged = false
    @Namespace private var animation
    private let analytics: AlfieAnalyticsTracker

    init(viewFactory: ViewFactory? = nil, analytics: AlfieAnalyticsTracker) {
        self.viewFactory = viewFactory
        self.analytics = analytics
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
            Text.build(theme.font.header.h3(L10n.Home.title))
            ThemedButton(text: isUserLogged ? L10n.Home.SignOut.Button.cta : L10n.Home.SignIn.Button.cta) {
                isUserLogged.toggle()
                analytics.track(.state(isUserLogged ? .userLogin : .userLogout, nil))
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
    HomeView(analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker())
        .environmentObject(Coordinator())
}
