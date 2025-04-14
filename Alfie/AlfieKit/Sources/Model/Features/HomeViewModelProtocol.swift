import Foundation

public protocol HomeViewModelProtocol: ObservableObject {
    var homeTitle: String { get }
    var signInButtonText: String { get }
    var username: String? { get }
    var memberSince: Int? { get }

    func didTapSignInButton()
}
