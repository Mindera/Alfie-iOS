import Combine
import Foundation
import Model

// TODO: Update with an actual implementation with network APIs
public final class SessionService: SessionServiceProtocol {
    public var isUserSignedInPublisher: AnyPublisher<Bool, Never> {
        $isUserSignedIn.eraseToAnyPublisher()
    }

    @Published private var isUserSignedIn: Bool
    private let analytics: AlfieAnalyticsTracker
    private var subscriptions: Set<AnyCancellable> = []

    public init(analytics: AlfieAnalyticsTracker) {
        self.isUserSignedIn = false
        self.analytics = analytics

        setupBindings()
    }

    private func setupBindings() {
        // TODO: Analytics shouldn't be part of Services, this should have a more generic handle like an AppViewModel
        isUserSignedInPublisher
            .dropFirst()
            .sink { [weak self] isUserSignedIn in
                guard let self else { return }
                analytics.trackUser(isSignedIn: isUserSignedIn)
            }
            .store(in: &subscriptions)
    }

    public func signInUser() {
        isUserSignedIn = true
    }

    public func signOutUser() {
        isUserSignedIn = false
    }
}
