import Foundation

public protocol AccountViewModelProtocol2: ObservableObject {
    var sectionList: [AccountSection2] { get }

    func didTapWishlist()
    func didTapSignIn()
    func didTapSignOut()
}
