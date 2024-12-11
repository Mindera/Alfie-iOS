import SwiftUI

public struct CoordinatedView<
    Coordinator: CoordinatorProtocol,
    ViewFactory: ViewFactoryProtocol<Coordinator.Screen>
>: View {
    private let rootScreen: Coordinator.Screen
    private let rootView: ViewFactory.ViewForScreen
    private var isWishlistEnabled: Bool

    public var coordinator: Coordinator {
        Coordinator(navigationAdapter: navigationAdapter, isWishlistEnabled: isWishlistEnabled)
    }

    @ObservedObject public private(set) var navigationAdapter: NavigationAdapter<Coordinator.Screen> = .init()
    @ObservedObject private var viewFactory: ViewFactory

    public init(rootScreen: Coordinator.Screen, viewFactory: ViewFactory = .init(), isWishlistEnabled: Bool) {
        self.rootScreen = rootScreen
        self.isWishlistEnabled = isWishlistEnabled
        _viewFactory = ObservedObject(wrappedValue: viewFactory)
        self.rootView = viewFactory.view(for: rootScreen)
    }

    public var body: some View {
        ZStack {
            NavigationStack(path: $navigationAdapter.path) {
                rootView
                    .navigationDestination(for: Coordinator.Screen.self) { screen in
                        viewFactory.view(for: screen)
                    }
                    .sheet(isPresented: $navigationAdapter.isPresentingSheet) {
                        navigationStack(for: navigationAdapter.sheet)
                    }
                    .fullScreenCover(isPresented: $navigationAdapter.isPresentingFullScreenCover) {
                        navigationStack(for: navigationAdapter.fullScreenCover)
                    }
            }

            if let overlay = navigationAdapter.fullScreenOverlay {
                navigationStack(for: overlay)
            }
        }
        .environmentObject(coordinator)
        .environmentObject(viewFactory)
    }
}

private extension CoordinatedView {
    func navigationStack(for modal: Coordinator.Screen?) -> some View {
        NavigationStack(path: $navigationAdapter.modalPath) {
            if let modal {
                viewFactory.view(for: modal)
                    .navigationDestination(for: Coordinator.Screen.self) { screen in
                        viewFactory.view(for: screen)
                    }
            }
        }.environmentObject(coordinator)
    }
}
