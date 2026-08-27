import Combine
import Foundation

/// The single owner of the shopper's cart. Callers read `cart` — or observe `cartPublisher` — and
/// never fetch a copy of their own, so the bag screen and the tab badge cannot drift apart.
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
