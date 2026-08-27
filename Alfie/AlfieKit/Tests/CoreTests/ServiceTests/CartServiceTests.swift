@testable import Core
import Mocks
import Model
import TestUtils
import XCTest

final class CartServiceTests: XCTestCase {

    // MARK: - First add

    func test_add_withNoStoredCartId_createsTheCartCarryingTheLine() async throws {
        let (sut, client, _) = makeSUT()
        var createdLines: [CartLineInput] = []
        client.onCreateCartCalled = { lines in
            createdLines = lines
            return .fixture(id: "cart-1")
        }

        try await sut.add(line: .init(productId: "p1", variantId: "v1"))

        XCTAssertEqual(createdLines.map(\.productId), ["p1"])
        XCTAssertEqual(createdLines.map(\.variantId), ["v1"])
    }

    func test_add_withNoStoredCartId_isASingleRoundTrip() async throws {
        // `createCart` carries the first line, so creating and adding is one request rather than
        // a create followed by an add.
        let (sut, client, _) = makeSUT()
        var addCallCount = 0
        client.onCreateCartCalled = { _ in .fixture(id: "cart-1") }
        client.onAddToCartCalled = { _, _ in
            addCallCount += 1
            return .fixture(id: "cart-1")
        }

        try await sut.add(line: .init(productId: "p1", variantId: "v1"))

        XCTAssertEqual(addCallCount, 0)
    }

    func test_add_withNoStoredCartId_persistsTheReturnedCartId() async throws {
        let (sut, client, userDefaults) = makeSUT()
        client.onCreateCartCalled = { _ in .fixture(id: "cart-1") }
        var persisted: [String: String] = [:]
        userDefaults.onSetCalled = { value, key in persisted[key] = value as? String }

        try await sut.add(line: .init(productId: "p1", variantId: "v1"))

        XCTAssertEqual(persisted[Self.storageKey], "cart-1")
    }

    // MARK: - Subsequent add

    func test_add_withAStoredCartId_appendsToThatCartAndDoesNotCreate() async throws {
        let (sut, client, _) = makeSUT(storedCartId: "cart-1")
        var createCallCount = 0
        var addedCartId: String?
        client.onCreateCartCalled = { _ in
            createCallCount += 1
            return .fixture(id: "other")
        }
        client.onAddToCartCalled = { cartId, _ in
            addedCartId = cartId
            return .fixture(id: "cart-1")
        }

        try await sut.add(line: .init(productId: "p2", variantId: "v2"))

        XCTAssertEqual(addedCartId, "cart-1")
        XCTAssertEqual(createCallCount, 0)
    }

    func test_add_replacesTheHeldCartWholesaleWithTheReturnedOne() async throws {
        // Every mutation returns the complete cart, so the response *is* the new truth. Nothing is
        // merged client-side, which is what stops two copies of the cart drifting apart.
        let (sut, client, _) = makeSUT(storedCartId: "cart-1")
        client.onAddToCartCalled = { _, _ in
            .fixture(id: "cart-1", lines: [.fixture(id: "line-1", variantId: "v1", quantity: 3)])
        }

        try await sut.add(line: .init(productId: "p1", variantId: "v1"))

        XCTAssertEqual(sut.cart?.lines.map(\.id), ["line-1"])
        XCTAssertEqual(sut.cart?.totalQuantity, 3)
    }

    func test_add_ofAVariantAlreadyInTheCart_takesTheServersMergedCart() async throws {
        // The platform merges a duplicate variant into the existing line with the quantity summed
        // (pinned end to end by CartIntegrationTests). The client must not second-guess that by
        // appending a row of its own.
        let (sut, client, _) = makeSUT(storedCartId: "cart-1")
        client.onAddToCartCalled = { _, _ in
            .fixture(id: "cart-1", lines: [.fixture(id: "line-1", variantId: "v1", quantity: 2)])
        }

        try await sut.add(line: .init(productId: "p1", variantId: "v1"))

        XCTAssertEqual(sut.cart?.lines.count, 1)
        XCTAssertEqual(sut.cart?.lines.first?.quantity, 2)
    }

    // MARK: - Observation

    func test_cart_isNilBeforeAnythingIsAdded() {
        let (sut, _, _) = makeSUT(storedCartId: "cart-1")

        // A stored id is not a cart: nothing is fetched until someone asks for the contents.
        XCTAssertNil(sut.cart)
    }

    func test_cartPublisher_emitsTheCartOnEveryWrite() async throws {
        let (sut, client, _) = makeSUT()
        client.onCreateCartCalled = { _ in .fixture(id: "cart-1") }
        var emitted: [String?] = []
        let cancellable = sut.cartPublisher.sink { emitted.append($0?.id) }
        defer { cancellable.cancel() }

        try await sut.add(line: .init(productId: "p1", variantId: "v1"))

        XCTAssertEqual(emitted, [nil, "cart-1"])
    }

    // MARK: - Failure

    func test_add_thatFails_propagatesAndLeavesTheHeldCartUntouched() async {
        let (sut, client, userDefaults) = makeSUT()
        client.onCreateCartCalled = { _ in throw BFFRequestError(type: .generic) }
        var persistedKeys: [String] = []
        userDefaults.onSetCalled = { _, key in persistedKeys.append(key) }

        do {
            try await sut.add(line: .init(productId: "p1", variantId: "v1"))
            XCTFail("Expected the failure to propagate")
        } catch {
            XCTAssertNil(sut.cart)
            XCTAssertTrue(persistedKeys.isEmpty)
        }
    }

    // MARK: - Helpers

    private static let storageKey = "cartId"

    private func makeSUT(
        storedCartId: String? = nil
    ) -> (CartService, MockBFFClientService, MockUserDefaults) {
        let client = MockBFFClientService()
        let userDefaults = MockUserDefaults()
        if let storedCartId {
            userDefaults.forcedValueForKey[Self.storageKey] = storedCartId
        }
        let sut = CartService(bffClient: client, userDefaults: userDefaults, storageKey: Self.storageKey)
        return (sut, client, userDefaults)
    }
}
