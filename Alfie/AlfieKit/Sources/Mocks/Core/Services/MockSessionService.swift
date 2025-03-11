import Combine
import Foundation
import Models

public final class MockSessionService: SessionServiceProtocol {
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

    @Published
    private var isUserLogged: Bool

    public init() {
        self.isUserLogged = false
    }
}
