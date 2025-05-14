import Foundation
import SwiftUI

public protocol HomeViewModelProtocol: ObservableObject {
    var homeTitle: String { get }
    var signInButtonText: String { get }
    var username: String? { get }
    var memberSince: Int? { get }
    var fullScreenCover: AnyView? { get set }

    func didTapSignInButton()
    func didTapDebugMenu()
    func didTapMyAccount()
    func didTapSearch()
}
