import Foundation

public protocol AccountViewModelProtocol: ObservableObject {
    var sectionList: [AccountSection] { get }

    func didTapWishlist()
    func didTapSignIn()
    func didTapSignOut()
}
