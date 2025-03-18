import Combine
import Models
import SwiftUI

public class HomeViewModel: HomeViewModelProtocol {
    private let sessionService: SessionServiceProtocol
    @Published private var isUserSignIn = false
    private var subscriptions: Set<AnyCancellable> = []

    public var homeTitle: String {
        L10n.Home.title
    }

    public var signInButtonText: String {
        isUserSignIn ? L10n.Home.SignOut.Button.cta : L10n.Home.SignIn.Button.cta
    }

    public var username: String? {
        isUserSignIn ? "Alfie" : nil
    }

    public var memberSince: Int? {
        isUserSignIn ? 2024 : nil
    }

    init(sessionService: SessionServiceProtocol) {
        self.sessionService = sessionService

        setupBindings()
    }

    private func setupBindings() {
        sessionService.isUserSignInPublisher
            .assignWeakly(to: \.isUserSignIn, on: self)
            .store(in: &subscriptions)
    }

    public func didTapSignInButton() {
        if isUserSignIn {
            sessionService.logoutUser()
        } else {
            sessionService.loginUser()
        }
    }
}
