import Combine
import Foundation
import Models

public final class MockSessionService: SessionServiceProtocol {
    public var isUserLoggedPublisher: AnyPublisher<Bool, Never> {
        $isUserLogged.eraseToAnyPublisher()
    }

    @Published private var isUserLogged: Bool

    public init() {
        self.isUserLogged = false
    }

    public func loginUser() {
        isUserLogged = true
    }

    public func logoutUser() {
        isUserLogged = false
    }
}
