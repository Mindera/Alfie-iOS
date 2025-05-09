import Combine
import Model
import SharedUI
import SwiftUI

class HomeViewModel2: HomeViewModelProtocol2, ObservableObject {
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

    init(
        sessionService: SessionServiceProtocol,
        navigate: @escaping (HomeRoute) -> Void,
        showSearch: @escaping () -> Void
    ) {
        self.sessionService = sessionService
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

    func didTapMyAccount() {
        navigate(.myAccount(.myAccount))
    }

    func didTapSearch() {
        showSearch()
    }
}
