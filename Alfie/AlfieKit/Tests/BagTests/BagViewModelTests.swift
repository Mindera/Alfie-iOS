import AlicerceLogging
import Combine
import Mocks
import Model
import TestUtils
import XCTest
@testable import Bag

private extension ViewState where Value == Cart?, StateError == BFFRequestError {
    /// Flattens the `Cart??` that `value` returns: the outer optional is "not loaded yet", the
    /// inner one is "no cart on the server". A test asserting on the bag only cares about the cart.
    var cart: Cart? { value ?? nil }
}

final class BagViewModelTests: XCTestCase {
    private var sut: BagViewModel!
    private var mockCartService: MockCartService!
    private var mockAnalytics: MockAnalyticsTracker!
    private var mockDependencies: BagDependencyContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockCartService = MockCartService()
        mockAnalytics = MockAnalyticsTracker()
        mockDependencies = BagDependencyContainer(
            cartService: mockCartService,
            configurationService: MockConfigurationService(),
            analytics: mockAnalytics.eraseToAnyAnalyticsTracker(),
            log: Log.DummyLogger()
        )
        sut = .init(dependencies: mockDependencies) { _ in }
    }

    override func tearDownWithError() throws {
        sut = nil
        mockCartService = nil
        mockAnalytics = nil
        mockDependencies = nil
        try super.tearDownWithError()
    }

    // MARK: - Reading the bag

    func test_viewDidAppear_showsTheCartTheServerReturns() {
        mockCartService.onFetchCalled = {
            .fixture(id: "cart-1", lines: [.fixture(id: "line-1", quantity: 2)])
        }

        XCTAssertEmitsValue(from: sut.$state, where: { $0.isSuccess }, afterTrigger: { self.sut.viewDidAppear() })

        let cart = sut.state.cart
        XCTAssertEqual(cart?.lines.map(\.id), ["line-1"])
        XCTAssertEqual(cart?.totalQuantity, 2)
    }

    func test_viewDidAppear_whenTheReadFails_showsTheError() {
        // The type has to survive into the state: the view picks its message from it, and offline
        // reads differently from a server fault.
        mockCartService.onFetchCalled = { throw BFFRequestError(type: .noInternet) }

        XCTAssertEmitsValue(from: sut.$state, where: { $0.didFail }, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.state.failure?.type, .noInternet)
    }

    func test_didTapRetry_readsAgainAndRecoversFromTheError() {
        mockCartService.onFetchCalled = { throw BFFRequestError(type: .noInternet) }
        XCTAssertEmitsValue(from: sut.$state, where: { $0.didFail }, afterTrigger: { self.sut.viewDidAppear() })

        mockCartService.onFetchCalled = { .fixture(id: "cart-1", lines: [.fixture(id: "line-1")]) }
        XCTAssertEmitsValue(from: sut.$state, where: { $0.isSuccess }, afterTrigger: { self.sut.didTapRetry() })

        let cart = sut.state.cart
        XCTAssertEqual(cart?.lines.map(\.id), ["line-1"])
    }

    func test_viewDidAppear_withACartAlreadyOnScreen_reReadsWithoutFlashingTheSkeleton() {
        // Every switch back to the Bag tab re-reads. Dropping to `.loading` first would blink the
        // skeleton over a bag the shopper is already looking at.
        showCart(.fixture(id: "cart-1", lines: [.fixture(id: "line-1")]))
        var sawLoading = false
        let cancellable = sut.$state.sink { if $0.isLoading { sawLoading = true } }
        defer { cancellable.cancel() }

        XCTAssertEmitsValue(from: sut.$state, where: { $0.isSuccess }, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertFalse(sawLoading)
    }

    // MARK: - An empty bag

    func test_aShopperWithNoCartSeesAnEmptyBagRatherThanAnError() {
        // Nothing has gone wrong for someone who has never added anything, so the screen must not
        // offer them a retry button for a request that was never going to happen.
        mockCartService.onFetchCalled = { nil }

        XCTAssertEmitsValue(from: sut.$state, where: { $0.isSuccess }, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertNil(sut.state.cart)
        XCTAssertFalse(sut.state.didFail)
    }

    func test_aCartWithNoLinesIsAnEmptyBagRatherThanAnError() {
        // The other shape of empty: a cart that exists on the server but has had everything
        // removed from it.
        mockCartService.onFetchCalled = { .fixture(id: "cart-1", lines: []) }

        XCTAssertEmitsValue(from: sut.$state, where: { $0.isSuccess }, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.state.cart?.lines, [])
        XCTAssertFalse(sut.state.didFail)
    }

    // MARK: - Removing a line

    func test_didSelectDelete_dropsTheLineOnTheServerAndTakesTheTotalsItReturns() {
        // The totals are the server's to recalculate. Dropping the row locally and leaving a
        // subtotal that still counts it is the failure this guards against.
        let line = CartLine.fixture(id: "line-1")
        showCart(.fixture(
            id: "cart-1",
            lines: [line, .fixture(id: "line-2")],
            subtotal: .fixture(amount: 4000),
            grandTotal: .fixture(amount: 4000)
        ))
        var removedLineId: String?
        mockCartService.onRemoveCalled = { lineId in
            removedLineId = lineId
            return .fixture(
                id: "cart-1",
                lines: [.fixture(id: "line-2")],
                subtotal: .fixture(amount: 2000),
                grandTotal: .fixture(amount: 2000)
            )
        }

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.cart?.lines.count == 1 },
            afterTrigger: { self.sut.didSelectDelete(line) }
        )

        XCTAssertEqual(removedLineId, "line-1")
        let cart = sut.state.cart
        XCTAssertEqual(cart?.lines.map(\.id), ["line-2"])
        XCTAssertEqual(cart?.subtotal.amount, 2000)
        XCTAssertEqual(cart?.grandTotal.amount, 2000)
    }

    func test_didSelectDelete_tracksTheRemovalOnceTheServerHasConfirmedIt() {
        let line = CartLine.fixture(id: "line-1")
        showCart(.fixture(id: "cart-1", lines: [line]))
        mockCartService.onRemoveCalled = { _ in .fixture(id: "cart-1", lines: []) }

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.cart?.lines.isEmpty == true },
            afterTrigger: { self.sut.didSelectDelete(line) }
        )

        XCTAssertEqual(mockAnalytics.trackedActions, [.removeFromBag])
    }

    func test_didSelectDelete_thatFails_tracksNothingAndLeavesTheBagStanding() {
        // A removal the server rejected did not happen. Reporting it would count removals that
        // never took place, and blanking the row would tell the shopper it did.
        let line = CartLine.fixture(id: "line-1")
        showCart(.fixture(id: "cart-1", lines: [line, .fixture(id: "line-2")]))
        mockCartService.onRemoveCalled = { _ in throw BFFRequestError(type: .noInternet) }

        XCTAssertNoEmit(from: sut.$state, afterTrigger: { self.sut.didSelectDelete(line) })

        XCTAssertEqual(mockAnalytics.trackedActions, [])
        XCTAssertEqual(sut.state.cart?.lines.map(\.id), ["line-1", "line-2"])
    }

    // MARK: - Helpers

    /// Puts the view model into `.success` holding `cart`, the state every removal starts from.
    private func showCart(_ cart: Cart) {
        mockCartService.onFetchCalled = { cart }
        XCTAssertEmitsValue(from: sut.$state, where: { $0.isSuccess }, afterTrigger: { self.sut.viewDidAppear() })
    }
}
