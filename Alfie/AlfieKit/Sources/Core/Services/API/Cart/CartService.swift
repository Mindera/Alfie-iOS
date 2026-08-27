import Combine
import Foundation
import Model

/// An actor, matching the other stores that own mutable state, so the cart and its id are only
/// ever touched from one isolation domain.
///
/// Note this does not make two concurrent adds safe — an actor is reentrant, so both could see no
/// stored id and create a cart apiece. Nothing today can reach that: the only caller disables its
/// CTA for the duration of the write. Revisit if a second writer appears.
public actor CartService: CartServiceProtocol {
    private let bffClient: BFFClientServiceProtocol
    private let userDefaults: UserDefaultsProtocol
    private let storageKey: String
    private let cartSubject = CurrentValueSubject<Cart?, Never>(nil)

    public nonisolated var cart: Cart? { cartSubject.value }
    public nonisolated var cartPublisher: AnyPublisher<Cart?, Never> { cartSubject.eraseToAnyPublisher() }

    public init(bffClient: BFFClientServiceProtocol, userDefaults: UserDefaultsProtocol, storageKey: String) {
        self.bffClient = bffClient
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    public func add(line: CartLineInput) async throws {
        // The first add creates the cart carrying the line, so create-and-add costs one round trip
        // rather than two.
        let cart: Cart
        if let cartId = storedCartId {
            cart = try await bffClient.addToCart(cartId: cartId, lines: [line])
        } else {
            cart = try await bffClient.createCart(lines: [line])
        }

        // Persisted from either branch: the returned cart is the truth, its id included. On
        // BigCommerce an append can hand back a cart whose id is not the one we asked with, and a
        // stored id that disagrees with the cart we hold is the next write aimed at the wrong one.
        userDefaults.set(cart.id, for: storageKey)
        cartSubject.send(cart)
    }

    /// The server's handle on a guest cart — a non-secret id, so `UserDefaults` is enough. There is
    /// no client-side expiry: the server's 404 is the only authoritative signal that a cart is dead.
    private var storedCartId: String? {
        userDefaults.value(for: storageKey)
    }
}
