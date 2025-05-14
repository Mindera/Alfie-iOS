import Foundation
import Model
import SwiftUI

public class MockHomeViewModel: HomeViewModelProtocol {
    public var homeTitle: String = "Home"
    public var signInButtonText: String = "Sign in"
    public var username: String?
    public var memberSince: Int?
    public var fullScreenCover: AnyView?

    public var onDidTapSignInButtonCalled: (() -> Void)?
    public func didTapSignInButton() {
        onDidTapSignInButtonCalled?()
    }

    public var onDidTapDebugMenuCalled: (() -> Void)?
    public func didTapDebugMenu() {
        onDidTapDebugMenuCalled?()
    }

    public var onDidTapMyAccountCalled: (() -> Void)?
    public func didTapMyAccount() {
        onDidTapMyAccountCalled?()
    }

    public var onDidTapSearchCalled: (() -> Void)?
    public func didTapSearch() {
        onDidTapSearchCalled?()
    }

    public init() { }
}
