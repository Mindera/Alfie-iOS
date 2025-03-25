import Combine
import Models
import SwiftUI

public class HomeViewModel: HomeViewModelProtocol {
    private let sessionService: SessionServiceProtocol
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

    init(sessionService: SessionServiceProtocol) {
        self.sessionService = sessionService

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
}
