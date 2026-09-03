import Combine
import Foundation
import Model

public final class MockCartService: CartServiceProtocol {
    private let cartSubject = CurrentValueSubject<Cart?, Never>(nil)

    public var cart: Cart? { cartSubject.value }
    public var cartPublisher: AnyPublisher<Cart?, Never> { cartSubject.eraseToAnyPublisher() }

    public var onAddCalled: ((CartLineInput) async throws -> Cart)?

    public init() { }

    public func add(line: CartLineInput) async throws {
        guard let cart = try await onAddCalled?(line) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        cartSubject.send(cart)
    }
}
