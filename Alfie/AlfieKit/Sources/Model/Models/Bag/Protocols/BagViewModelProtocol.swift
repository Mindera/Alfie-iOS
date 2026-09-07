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
    /// Opens the line's product detail page. A line with no slug has nowhere to go and does
    /// nothing — the row renders inert for the same reason, so a tap can only ever arrive for a
    /// line that carries one. The guard here is what makes that a contract of the type rather than
    /// a promise the view happens to keep.
    func didSelectLine(_ line: CartLine)
    func didDismissRemovalFailure()
    func didTapMyAccount()
    func didTapWishlist()
}
