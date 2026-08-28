import Foundation

public protocol BagViewModelProtocol: ObservableObject {
    /// `nil` inside `.success` is a shopper with no cart on the server. The view treats that and a
    /// cart with no lines identically — both are an empty bag, neither is an error.
    var state: ViewState<Cart?, BFFRequestError> { get }
    var isWishlistEnabled: Bool { get }

    func viewDidAppear()
    func didTapRetry()
    func didSelectDelete(_ line: CartLine)
    func didTapMyAccount()
    func didTapWishlist()
}
