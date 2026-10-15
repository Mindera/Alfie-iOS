import Combine
import Foundation
import Model

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
