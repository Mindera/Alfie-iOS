import Foundation

public protocol BagViewModelProtocol: ObservableObject {
    /// `nil` inside `.success` is a shopper with no cart on the server. The view treats that and a
    /// cart with no lines identically — both are an empty bag, neither is an error.
    var state: ViewState<Cart?, BFFRequestError> { get }
    var isWishlistEnabled: Bool { get }
    /// Why the last removal failed, surfaced as a Snackbar and cleared when it is dismissed. A
    /// blocked write tells the shopper so rather than leaving the row to snap back in silence
    /// (Q25). The type rather than the error because the view only picks copy from it — and
    /// `BFFRequestError` is not `Equatable`, so `onChange` could not observe it.
    var removalFailure: BFFRequestError.BFFRequestErrorType? { get }

    func viewDidAppear()
    func didTapRetry()
    func didSelectDelete(_ line: CartLine)
    func didDismissRemovalFailure()
    func didTapMyAccount()
    func didTapWishlist()
}
