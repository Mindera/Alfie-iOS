import Foundation
import Models

public class MockHomeViewModel: HomeViewModelProtocol {
    public var homeTitle: String { "Home" }
    public var signInButtonText: String { "Sign in" }
    public var username: String? { nil }
    public var memberSince: Int? { nil }

    public var onDidTapSignInButtonCalled: (() -> Void)?
    public func didTapSignInButton() {
        onDidTapSignInButtonCalled?()
    }

    public init() { }
}
