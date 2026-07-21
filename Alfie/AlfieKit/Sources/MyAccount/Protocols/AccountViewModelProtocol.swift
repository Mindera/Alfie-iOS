import Foundation
import SwiftUI

public protocol AccountViewModelProtocol: ObservableObject {
    var sectionList: [AccountSection] { get }
    var fullScreenCover: AnyView? { get set }

    func didTapWishlist()
    func didTapSignIn()
    func didTapSignOut()
    func didTapSettings()
}
