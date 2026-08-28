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

    func test_add_persistsTheCartIdAnAppendReturns_evenWhenItDiffers() async throws {
        // On BigCommerce a write can hand back a cart whose id is not the one it was asked with.
        // The returned cart is the truth, so the stored id follows it rather than the request.
        let (sut, client, userDefaults) = makeSUT(storedCartId: "cart-1")
        client.onAddToCartCalled = { _, _ in .fixture(id: "cart-2") }
        var persisted: [String: String] = [:]
        userDefaults.onSetCalled = { value, key in persisted[key] = value as? String }

        try await sut.add(line: .init(productId: "p1", variantId: "v1"))

        XCTAssertEqual(persisted[Self.storageKey], "cart-2")
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

    // MARK: - Concurrent adds

    func test_add_whileAnotherAddIsInFlight_waitsForItRatherThanCreatingACartOfItsOwn() async throws {
        // Two adds can be in flight at once: the CTA guard is `ProductDetailsViewModel`'s
        // `isAddingToBag`, which covers one screen, and there is a view model per tab flow.
        // Unserialised, both would see no stored id and create a cart apiece — leaving the first
        // item in a cart whose id was overwritten before anything could read it back.
        let (sut, client, userDefaults) = makeSUT()
        // The mock does not serve its own writes back to reads, so mirror what `UserDefaults` does.
        userDefaults.onSetCalled = { [weak userDefaults] value, key in
            userDefaults?.forcedValueForKey[key] = value
        }
        let gate = WriteGate()
        let firstCreateInFlight = expectation(description: "the first add's create is in-flight")
        let secondCreateAttempted = expectation(description: "the second add must not create a cart")
        secondCreateAttempted.isInverted = true
        client.onCreateCartCalled = { _ in
            await gate.recordCreateAndMaybeWait(signal: firstCreateInFlight, secondSignal: secondCreateAttempted)
            return .fixture(id: "cart-1")
        }
        client.onAddToCartCalled = { cartId, _ in
            await gate.recordAppend(toCartId: cartId)
            return .fixture(id: "cart-1")
        }

        async let firstAdd: Void = sut.add(line: .init(productId: "p1", variantId: "v1"))
        await fulfillment(of: [firstCreateInFlight], timeout: 1)

        async let secondAdd: Void = sut.add(line: .init(productId: "p2", variantId: "v2"))
        await fulfillment(of: [secondCreateAttempted], timeout: 0.5)

        await gate.open()
        try await firstAdd
        try await secondAdd

        let creates = await gate.creates
        let appendedCartIds = await gate.appendedCartIds
        XCTAssertEqual(creates, 1)
        // The second add appended to the cart the first one created, rather than starting another.
        XCTAssertEqual(appendedCartIds, ["cart-1"])
    }

    func test_add_afterAnAddThatFailed_stillRuns() async throws {
        // Writes queue behind one another, so a failure must not take the next write down with it.
        let (sut, client, _) = makeSUT()
        client.onCreateCartCalled = { _ in throw BFFRequestError(type: .generic) }

        async let failing: Void = sut.add(line: .init(productId: "p1", variantId: "v1"))
        _ = try? await failing

        client.onCreateCartCalled = { _ in .fixture(id: "cart-1") }
        try await sut.add(line: .init(productId: "p2", variantId: "v2"))

        XCTAssertEqual(sut.cart?.id, "cart-1")
    }

    // MARK: - Fetch

    func test_fetch_withNoStoredCartId_publishesNoCartWithoutAskingTheServer() async throws {
        // A shopper who has never added anything has no cart on the server to read. Asking for one
        // anyway would be a round trip whose only possible answer is the empty bag we already know.
        let (sut, client, _) = makeSUT()
        var getCallCount = 0
        client.onGetCartCalled = { _ in
            getCallCount += 1
            return .fixture(id: "cart-1")
        }

        try await sut.fetch()

        XCTAssertEqual(getCallCount, 0)
        XCTAssertNil(sut.cart)
    }

    func test_fetch_withAStoredCartId_readsThatCartAndPublishesIt() async throws {
        let (sut, client, _) = makeSUT(storedCartId: "cart-1")
        var requestedCartId: String?
        client.onGetCartCalled = { cartId in
            requestedCartId = cartId
            return .fixture(id: "cart-1", lines: [.fixture(id: "line-1", quantity: 2)])
        }

        try await sut.fetch()

        XCTAssertEqual(requestedCartId, "cart-1")
        XCTAssertEqual(sut.cart?.lines.map(\.id), ["line-1"])
        XCTAssertEqual(sut.cart?.totalQuantity, 2)
    }

    func test_fetch_thatFails_propagatesAndLeavesTheHeldCartUntouched() async throws {
        // The bag turns a thrown error into its error state. Blanking the held cart on the way
        // would also blank the tab badge, which has no reason to forget what it last knew.
        let (sut, client, _) = makeSUT(storedCartId: "cart-1")
        client.onAddToCartCalled = { _, _ in .fixture(id: "cart-1", lines: [.fixture(id: "line-1")]) }
        try await sut.add(line: .init(productId: "p1", variantId: "v1"))
        client.onGetCartCalled = { _ in throw BFFRequestError(type: .noInternet) }

        do {
            try await sut.fetch()
            XCTFail("Expected the failure to propagate")
        } catch {
            XCTAssertEqual((error as? BFFRequestError)?.type, .noInternet)
            XCTAssertEqual(sut.cart?.lines.map(\.id), ["line-1"])
        }
    }

    // MARK: - Remove

    func test_remove_asksTheServerToDropTheLineAndTakesTheCartItReturns() async throws {
        let (sut, client, _) = makeSUT(storedCartId: "cart-1")
        var request: (cartId: String, lineId: String)?
        client.onRemoveFromCartCalled = { cartId, lineId in
            request = (cartId, lineId)
            return .fixture(id: "cart-1", lines: [.fixture(id: "line-2")])
        }

        try await sut.remove(lineId: "line-1")

        XCTAssertEqual(request?.cartId, "cart-1")
        XCTAssertEqual(request?.lineId, "line-1")
        XCTAssertEqual(sut.cart?.lines.map(\.id), ["line-2"])
    }

    func test_remove_whileAnAddIsInFlight_landsAfterItRatherThanBeingOverwrittenByIt() async throws {
        // A remove is a write like any other. Left unordered, its response can arrive first and the
        // add's older cart then overwrites it — the row the shopper swiped away reappears.
        let (sut, client, _) = makeSUT(storedCartId: "cart-1")
        let gate = WriteGate()
        let addInFlight = expectation(description: "the add is in-flight")
        let removeReachedServerDuringAdd = expectation(description: "the remove must wait for the add")
        removeReachedServerDuringAdd.isInverted = true
        client.onAddToCartCalled = { _, _ in
            await gate.holdOpen(signal: addInFlight)
            return .fixture(id: "cart-1", lines: [.fixture(id: "line-1"), .fixture(id: "line-2")])
        }
        client.onRemoveFromCartCalled = { _, _ in
            removeReachedServerDuringAdd.fulfill()
            return .fixture(id: "cart-1", lines: [.fixture(id: "line-2")])
        }

        async let add: Void = sut.add(line: .init(productId: "p1", variantId: "v1"))
        await fulfillment(of: [addInFlight], timeout: 1)
        async let removal: Void = sut.remove(lineId: "line-1")
        // The add is still held here, so any request the remove makes in this window is one that
        // jumped the queue.
        await fulfillment(of: [removeReachedServerDuringAdd], timeout: 0.5)

        await gate.open()
        try await add
        try await removal

        XCTAssertEqual(sut.cart?.lines.map(\.id), ["line-2"])
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

/// Holds the first cart write open so a second one can be started against it, and records what the
/// two of them asked the client for.
private actor WriteGate {
    private var continuation: CheckedContinuation<Void, Never>?
    private var opened = false
    private(set) var creates = 0
    private(set) var appendedCartIds: [String] = []

    func recordCreateAndMaybeWait(signal: XCTestExpectation, secondSignal: XCTestExpectation) async {
        creates += 1
        guard creates == 1 else {
            secondSignal.fulfill()
            return
        }
        signal.fulfill()
        guard !opened else { return }
        await withCheckedContinuation { continuation = $0 }
    }

    func recordAppend(toCartId cartId: String) {
        appendedCartIds.append(cartId)
    }

    /// Holds a write open, without counting it, so another can be started while it is in flight.
    func holdOpen(signal: XCTestExpectation) async {
        signal.fulfill()
        guard !opened else { return }
        await withCheckedContinuation { continuation = $0 }
    }

    func open() {
        opened = true
        continuation?.resume()
        continuation = nil
    }
}
