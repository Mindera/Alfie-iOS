import Combine
import Foundation
import Models

// TODO: Update with an actual implementation with network APIs
public final class SessionService: SessionServiceProtocol {
    public var isUserSignInPublisher: AnyPublisher<Bool, Never> {
        $isUserLogged.eraseToAnyPublisher()
    }

    @Published private var isUserLogged: Bool
    private let analytics: AlfieAnalyticsTracker
    private var subscriptions: Set<AnyCancellable> = []

    public init(analytics: AlfieAnalyticsTracker) {
        self.isUserLogged = false
        self.analytics = analytics

        setupBindings()
    }

    private func setupBindings() {
        // TODO: Analytics shouldn't be part of Services, this should have a more generic handle like an AppViewModel
        isUserSignInPublisher
            .dropFirst()
            .sink { [weak self] isUserSignIn in
                guard let self else { return }
                analytics.trackUser(isSignIn: isUserSignIn)
            }
            .store(in: &subscriptions)
    }

    public func loginUser() {
        isUserLogged = true
    }

    public func logoutUser() {
        isUserLogged = false
    }
}
