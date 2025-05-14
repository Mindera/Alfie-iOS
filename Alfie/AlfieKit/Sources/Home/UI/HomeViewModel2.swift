import Combine
import DebugMenu
import Model
import SharedUI
import SwiftUI

class HomeViewModel2: HomeViewModelProtocol2, ObservableObject {
    private let serviceProvider: ServiceProviderProtocol
    private let sessionService: SessionServiceProtocol
    private let navigate: (HomeRoute) -> Void
    private let showSearch: () -> Void
    @Published private var isUserSignedIn = false
    private var subscriptions: Set<AnyCancellable> = []

    var homeTitle: String {
        L10n.Home.title
    }

    var signInButtonText: String {
        isUserSignedIn ? L10n.Home.SignOut.Button.cta : L10n.Home.SignIn.Button.cta
    }

    var username: String? {
        isUserSignedIn ? "Alfie" : nil
    }

    var memberSince: Int? {
        isUserSignedIn ? 2024 : nil
    }

    @Published var fullScreenCover: AnyView?

    init(
        serviceProvider: ServiceProviderProtocol,
        navigate: @escaping (HomeRoute) -> Void,
        showSearch: @escaping () -> Void
    ) {
        self.serviceProvider = serviceProvider
        self.sessionService = serviceProvider.sessionService
        self.navigate = navigate
        self.showSearch = showSearch

        setupBindings()
    }

    private func setupBindings() {
        sessionService.isUserSignedInPublisher
            .assignWeakly(to: \.isUserSignedIn, on: self)
            .store(in: &subscriptions)
    }

    func didTapSignInButton() {
        if isUserSignedIn {
            sessionService.signOutUser()
        } else {
            sessionService.signInUser()
        }
    }

    func didTapDebugMenu() {
        fullScreenCover = AnyView(
            DebugMenuView(
                viewModel: DebugMenuViewModel(
                    serviceProvider: serviceProvider,
                    closeMenuAction: { [weak self] in self?.fullScreenCover = nil },
                    openForceAppUpdate: { [weak self] in
                        if let configuration = self?.serviceProvider.configurationService.forceAppUpdateInfo {
                            self?.fullScreenCover = AnyView(ForceAppUpdateView(configuration: configuration))
                        }
                    },
                    closeEndpointSelection: { [weak self] in self?.fullScreenCover = nil }
                )
            )
        )
    }

    func didTapMyAccount() {
        navigate(.myAccount(.myAccount))
    }

    func didTapSearch() {
        showSearch()
    }
}
