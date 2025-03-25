import Foundation
import Models

public class MockHomeViewModel: HomeViewModelProtocol {
    public var homeTitle: String = "Home"
    public var signInButtonText: String = "Sign in"
    public var username: String?
    public var memberSince: Int?

    public var onDidTapSignInButtonCalled: (() -> Void)?
    public func didTapSignInButton() {
        onDidTapSignInButtonCalled?()
    }

    public init() { }
}
