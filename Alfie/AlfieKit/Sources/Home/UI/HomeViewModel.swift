import Combine
import DebugMenu
import Model
import SharedUI
import SwiftUI

public class HomeViewModel: HomeViewModelProtocol, ObservableObject {
    private let sessionService: SessionServiceProtocol
    private let configurationService: ConfigurationServiceProtocol
    private let apiEndpointService: ApiEndpointServiceProtocol
    private let navigate: (HomeRoute) -> Void
    private let showSearch: () -> Void
    @Published private var isUserSignedIn = false
    private var subscriptions: Set<AnyCancellable> = []

    public var homeTitle: String {
        L10n.Home.title
    }

    public var signInButtonText: String {
        isUserSignedIn ? L10n.Home.SignOut.Button.cta : L10n.Home.SignIn.Button.cta
    }

    public var username: String? {
        isUserSignedIn ? "Alfie" : nil
    }

    public var memberSince: Int? {
        isUserSignedIn ? 2024 : nil
    }

    @Published public var fullScreenCover: AnyView?

    init(
        dependencies: HomeDependencyContainer,
        navigate: @escaping (HomeRoute) -> Void,
        showSearch: @escaping () -> Void
    ) {
        self.sessionService = dependencies.sessionService
        self.configurationService = dependencies.configurationService
        self.apiEndpointService = dependencies.apiEndpointService
        self.navigate = navigate
        self.showSearch = showSearch

        setupBindings()
    }

    private func setupBindings() {
        sessionService.isUserSignedInPublisher
            .assignWeakly(to: \.isUserSignedIn, on: self)
            .store(in: &subscriptions)
    }

    public func didTapSignInButton() {
        if isUserSignedIn {
            sessionService.signOutUser()
        } else {
            sessionService.signInUser()
        }
    }

    public func didTapDebugMenu() {
        fullScreenCover = AnyView(
            DebugMenuView(
                viewModel: DebugMenuViewModel(
                    configurationService: configurationService,
                    apiEndpointService: apiEndpointService,
                    closeMenuAction: { [weak self] in self?.fullScreenCover = nil
                    },
                    openForceAppUpdate: { [weak self] in
                        if let configuration = self?.configurationService.forceAppUpdateInfo {
                            self?.fullScreenCover = AnyView(ForceAppUpdateView(configuration: configuration))
                        }
                    },
                    closeEndpointSelection: { [weak self] in self?.fullScreenCover = nil }
                )
            )
        )
    }

    public func didTapMyAccount() {
        navigate(.myAccount(.myAccount))
    }

    public func didTapSearch() {
        showSearch()
    }
}
