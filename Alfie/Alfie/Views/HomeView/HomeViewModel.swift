import Combine
import Models
import SwiftUI

public class HomeViewModel: HomeViewModelProtocol {
    private let sessionService: SessionServiceProtocol
    @Published private var isUserLogged = false
    private var subscriptions: Set<AnyCancellable> = []

    public var homeTitle: String {
        L10n.Home.title
    }

    public var signInButtonText: String {
        isUserLogged ? L10n.Home.SignOut.Button.cta : L10n.Home.SignIn.Button.cta
    }

    public var username: String? {
        isUserLogged ? "Alfie" : nil
    }

    public var memberSince: Int? {
        isUserLogged ? 2024 : nil
    }

    init(sessionService: SessionServiceProtocol) {
        self.sessionService = sessionService

        setupBindings()
    }

    private func setupBindings() {
        sessionService.isUserLoggedPublisher
            .assignWeakly(to: \.isUserLogged, on: self)
            .store(in: &subscriptions)
    }

    public func didTapSignInButton() {
        if isUserLogged {
            sessionService.logoutUser()
        } else {
            sessionService.loginUser()
        }
    }
}
