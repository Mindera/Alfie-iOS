import Combine
import Foundation
import Model

public final class MockCartService: CartServiceProtocol {
    private let cartSubject = CurrentValueSubject<Cart?, Never>(nil)

    public var cart: Cart? { cartSubject.value }
    public var cartPublisher: AnyPublisher<Cart?, Never> { cartSubject.eraseToAnyPublisher() }

    public var onAddCalled: ((CartLineInput) async throws -> Cart)?

    public init() { }

    public var onFetchCalled: (() async throws -> Cart?)?

    public func add(line: CartLineInput) async throws {
        guard let cart = try await onAddCalled?(line) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        cartSubject.send(cart)
    }

    /// An unset closure throws rather than publishing `nil`, matching `add(line:)`. A silent
    /// success would let a test assert an empty bag while the mock was never configured at all;
    /// a closure that returns `nil` is still how a shopper with no server cart is modelled.
    public func fetch() async throws {
        guard let onFetchCalled else {
            throw BFFRequestError(type: .emptyResponse)
        }
        cartSubject.send(try await onFetchCalled())
    }

    public var onRemoveCalled: ((String) async throws -> Cart?)?

    public func remove(lineId: String) async throws {
        guard let onRemoveCalled else {
            throw BFFRequestError(type: .emptyResponse)
        }
        cartSubject.send(try await onRemoveCalled(lineId))
    }

    public private(set) var signOutCount = 0

    /// Unlike the operations above this needs no stub: it cannot fail and asks the server nothing,
    /// so dropping the held cart is the whole behaviour.
    public func signOut() async {
        signOutCount += 1
        cartSubject.send(nil)
    }
}
