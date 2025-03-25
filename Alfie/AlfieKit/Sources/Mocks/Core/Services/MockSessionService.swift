import Combine
import Foundation
import Models

public final class MockSessionService: SessionServiceProtocol {
    public var isUserSignedInPublisher: AnyPublisher<Bool, Never> {
        $isUserSignedIn.eraseToAnyPublisher()
    }

    @Published private var isUserSignedIn: Bool

    public init() {
        self.isUserSignedIn = false
    }

    public func signInUser() {
        isUserSignedIn = true
    }

    public func signOutUser() {
        isUserSignedIn = false
    }
}
