import Combine
import Foundation
import Models

// TODO: Update with an actual implementation with network APIs
public final class SessionService: SessionServiceProtocol {
    // MARK: SessionServiceProtocol

    public var isUserLoggedPublisher: AnyPublisher<Bool, Never> {
        $isUserLogged.eraseToAnyPublisher()
    }

    public func loginUser() {
        isUserLogged = true
    }

    public func logoutUser() {
        isUserLogged = false
    }

    // MARK: Lifecycle

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
        isUserLoggedPublisher
            .dropFirst()
            .sink { [weak self] isUserLogged in
                guard let self else { return }
                analytics.trackUser(isLoggedIn: isUserLogged)
            }
            .store(in: &subscriptions)
    }
}
