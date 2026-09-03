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
}
