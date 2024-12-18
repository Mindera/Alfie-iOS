import Models
import StyleGuide
import SwiftUI

struct HomeView: View {
    enum Constants {
        static let searchBarGeometryID = "SearchBar"
        static let searchAccessibility = "search-input"
        static let cancelAccessibilityId = "back-btn"
    }

    @EnvironmentObject var coordinador: Coordinator
    @Namespace private var animation
    @State private var showSearchBar = true
    @State private var isUserLogged = false

    private let viewFactory: ViewFactory?

    init(viewFactory: ViewFactory? = nil) {
        self.viewFactory = viewFactory
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
            ThemedButton(text: isUserLogged ? "Sign out" : "Sign in") {
                isUserLogged.toggle()
            }
            Spacer()
        }
        .withToolbar(for: .tab(.home(
            isUserLogged ? .loggedIn(username: "Alfie", memberSince: 2024) : .loggedOut
        )))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        // TODO: Remove debug menu for production releases
        .fullScreenCover(isPresented: $coordinador.isPresentingDebugMenu) {
            viewFactory?.view(for: .debugMenu)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(Coordinator())
}
