import Combine
import Foundation
import Models

public final class MockSessionService: SessionServiceProtocol {
    public var isUserSignInPublisher: AnyPublisher<Bool, Never> {
        $isUserSignIn.eraseToAnyPublisher()
    }

    @Published private var isUserSignIn: Bool

    public init() {
        self.isUserSignIn = false
    }

    public func loginUser() {
        isUserSignIn = true
    }

    public func logoutUser() {
        isUserSignIn = false
    }
}
