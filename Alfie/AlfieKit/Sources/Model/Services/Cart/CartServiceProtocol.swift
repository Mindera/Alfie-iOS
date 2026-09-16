import Combine
import Foundation

/// The single owner of the shopper's cart. Callers read `cart` — or observe `cartPublisher` — and
/// never fetch a copy of their own, so no two of them can drift apart. The readers arrive with the
/// bag screen (#117) and the tab badge (#118); today the cart is written here and read by tests.
///
/// Every server write returns the complete cart, so each one replaces the held cart wholesale.
public protocol CartServiceProtocol {
    /// The cart as the server last described it. `nil` until something is added or read: a stored
    /// cart id is not a cart, and nothing is fetched just to have one.
    var cart: Cart? { get }
    var cartPublisher: AnyPublisher<Cart?, Never> { get }

    /// Adds a line to the cart, creating the cart on the first add and persisting its id.
    func add(line: CartLineInput) async throws

    /// Reads the cart behind the stored id into `cart`. With no stored id there is nothing on the
    /// server to read, so this publishes `nil` without a round trip.
    func fetch() async throws

    /// Drops a line from the cart, taking the cart the server returns in its place.
    func remove(lineId: String) async throws

    /// Sets one line's quantity, leaving every other line as it is. A quantity of zero drops the
    /// line, so callers do not need a separate path for the last decrement.
    ///
    /// Throws when there is no cart to change, or when the held cart does not carry `lineId`: the
    /// request is assembled from the lines we hold, so a line we do not know about cannot be
    /// changed without rewriting the ones we do.
    func setQuantity(lineId: String, to quantity: Int) async throws

    /// Discards the stored cart id and the held cart, so a shared device does not hand the next
    /// shopper the previous one's bag. Nothing is asked of the server: a guest cart is not bound to
    /// an account, so the cart lives on until it expires — this side just stops pointing at it.
    func discardCart() async
}
