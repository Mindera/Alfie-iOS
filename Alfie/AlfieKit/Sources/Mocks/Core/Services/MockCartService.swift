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

    public func fetch() async throws {
        cartSubject.send(try await onFetchCalled?())
    }

    public var onRemoveCalled: ((String) async throws -> Cart?)?

    public func remove(lineId: String) async throws {
        cartSubject.send(try await onRemoveCalled?(lineId))
    }
}
