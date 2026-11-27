import AlicerceLogging
import Combine
import Mocks
import Model
import ProductDetails
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
    private var capturedRoutes: [BagRoute]!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockCartService = MockCartService()
        mockAnalytics = MockAnalyticsTracker()
        mockDependencies = BagDependencyContainer(
            cartService: mockCartService,
            analytics: mockAnalytics.eraseToAnyAnalyticsTracker(),
            log: Log.DummyLogger()
        )
        capturedRoutes = []
        sut = .init(dependencies: mockDependencies) { [weak self] in self?.capturedRoutes.append($0) }
    }

    override func tearDownWithError() throws {
        sut = nil
        mockCartService = nil
        mockAnalytics = nil
        mockDependencies = nil
        capturedRoutes = nil
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

    // MARK: - A failed re-read

    func test_a_failed_re_read_keeps_the_lines_and_reports_why() {
        showCart(.fixture(id: "cart-1", lines: [.fixture(id: "line-1")]))
        mockCartService.onFetchCalled = { throw BFFRequestError(type: .noInternet) }

        XCTAssertEmitsValue(
            from: sut.$transientFailure,
            where: { $0 == .noInternet },
            afterTrigger: { self.sut.viewDidAppear() }
        )

        XCTAssertEqual(sut.state.cart?.lines.map(\.id), ["line-1"])
    }

    func test_a_second_failed_re_read_reports_again_after_the_first_was_dismissed() {
        showCart(.fixture(id: "cart-1", lines: [.fixture(id: "line-1")]))
        mockCartService.onFetchCalled = { throw BFFRequestError(type: .noInternet) }
        XCTAssertEmitsValue(
            from: sut.$transientFailure,
            where: { $0 == .noInternet },
            afterTrigger: { self.sut.viewDidAppear() }
        )
        sut.didDismissTransientFailure()

        XCTAssertEmitsValue(
            from: sut.$transientFailure,
            where: { $0 == .noInternet },
            afterTrigger: { self.sut.viewDidAppear() }
        )
    }

    func test_a_cart_already_held_shows_its_lines_before_any_read() {
        mockCartService.send(cart: .fixture(id: "cart-1", lines: [.fixture(id: "line-1")]))

        sut = .init(dependencies: mockDependencies) { _ in }

        XCTAssertEqual(sut.state.cart?.lines.map(\.id), ["line-1"])
    }

    func test_a_failed_first_read_with_a_cart_already_held_keeps_the_lines_and_reports_why() {
        mockCartService.send(cart: .fixture(id: "cart-1", lines: [.fixture(id: "line-1")]))
        mockCartService.onFetchCalled = { throw BFFRequestError(type: .timeout) }
        sut = .init(dependencies: mockDependencies) { _ in }

        XCTAssertEmitsValue(
            from: sut.$transientFailure,
            where: { $0 == .timeout },
            afterTrigger: { self.sut.viewDidAppear() }
        )

        XCTAssertEqual(sut.state.cart?.lines.map(\.id), ["line-1"])
    }

    func test_a_failed_re_read_with_no_cart_is_a_blocking_error() {
        mockCartService.onFetchCalled = { nil }
        XCTAssertEmitsValue(from: sut.$state, where: { $0.isSuccess }, afterTrigger: { self.sut.viewDidAppear() })
        mockCartService.onFetchCalled = { throw BFFRequestError(type: .noInternet) }

        XCTAssertEmitsValue(from: sut.$state, where: { $0.didFail }, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.state.failure?.type, .noInternet)
        XCTAssertNil(sut.transientFailure)
    }

    func test_a_failed_re_read_over_a_cart_with_no_lines_is_a_blocking_error() {
        showCart(.fixture(id: "cart-1", lines: []))
        mockCartService.onFetchCalled = { throw BFFRequestError(type: .noInternet) }

        XCTAssertEmitsValue(from: sut.$state, where: { $0.didFail }, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.state.failure?.type, .noInternet)
        XCTAssertNil(sut.transientFailure)
    }

    // MARK: - Following the cart

    func test_a_cart_published_without_a_read_from_the_bag_updates_the_lines() {
        showCart(.fixture(id: "cart-1", lines: [.fixture(id: "line-1", quantity: 1)]))

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.cart?.totalQuantity == 3 },
            afterTrigger: {
                self.mockCartService.send(cart: .fixture(id: "cart-1", lines: [.fixture(id: "line-1", quantity: 3)]))
            }
        )
    }

    func test_a_cart_with_lines_published_during_a_blocking_error_shows_the_lines() {
        mockCartService.onFetchCalled = { throw BFFRequestError(type: .noInternet) }
        XCTAssertEmitsValue(from: sut.$state, where: { $0.didFail }, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.isSuccess },
            afterTrigger: { self.mockCartService.send(cart: .fixture(id: "cart-1", lines: [.fixture(id: "line-1")])) }
        )

        XCTAssertEqual(sut.state.cart?.lines.map(\.id), ["line-1"])
    }

    func test_a_nil_cart_published_empties_the_bag() {
        showCart(.fixture(id: "cart-1", lines: [.fixture(id: "line-1")]))

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.isSuccess && $0.cart == nil },
            afterTrigger: { self.mockCartService.send(cart: nil) }
        )
    }

    func test_a_nil_cart_published_during_a_blocking_error_empties_the_bag() {
        mockCartService.onFetchCalled = { throw BFFRequestError(type: .noInternet) }
        XCTAssertEmitsValue(from: sut.$state, where: { $0.didFail }, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.isSuccess && $0.cart == nil },
            afterTrigger: { self.mockCartService.send(cart: nil) }
        )
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
        XCTAssertEqual(cart?.subtotal?.amount, 2000)
        XCTAssertEqual(cart?.grandTotal?.amount, 2000)
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

        let tracked = XCTNSPredicateExpectation(
            predicate: NSPredicate { [mockAnalytics] _, _ in mockAnalytics?.trackedActions == [.removeFromBag] },
            object: nil
        )
        wait(for: [tracked], timeout: .default)
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

    func test_didSelectDelete_thatFails_reportsWhyRatherThanFailingInSilence() {
        // The bag is left standing, so without this the row snaps back and the shopper is told
        // nothing. The type has to survive so the Snackbar can tell offline from a server fault.
        let line = CartLine.fixture(id: "line-1")
        showCart(.fixture(id: "cart-1", lines: [line]))
        mockCartService.onRemoveCalled = { _ in throw BFFRequestError(type: .noInternet) }

        XCTAssertEmitsValue(
            from: sut.$transientFailure,
            where: { $0 == .noInternet },
            afterTrigger: { self.sut.didSelectDelete(line) }
        )
    }

    func test_didDismissTransientFailure_clearsIt() {
        // Cleared on dismissal so an identical later failure re-presents rather than being
        // swallowed as an unchanged value.
        let line = CartLine.fixture(id: "line-1")
        showCart(.fixture(id: "cart-1", lines: [line]))
        mockCartService.onRemoveCalled = { _ in throw BFFRequestError(type: .noInternet) }
        XCTAssertEmitsValue(
            from: sut.$transientFailure,
            where: { $0 != nil },
            afterTrigger: { self.sut.didSelectDelete(line) }
        )

        sut.didDismissTransientFailure()

        XCTAssertNil(sut.transientFailure)
    }

    // MARK: - Opening a line's product

    func test_did_select_line_opens_the_pdp_on_the_bagged_variant() {
        let line = CartLine.fixture(id: "line-1", variantId: "variant-9", sku: "SKU-9", slug: "silk-shirt")

        sut.didSelectLine(line)

        XCTAssertEqual(
            capturedRoutes,
            [.productDetails(.productDetails(.deepLink(handle: "silk-shirt", sku: "SKU-9", variantId: "variant-9")))]
        )
    }

    func test_did_select_line_with_no_sku_opens_the_variant_by_id() {
        let line = CartLine.fixture(id: "line-1", variantId: "variant-9", sku: nil, slug: "silk-shirt")

        sut.didSelectLine(line)

        XCTAssertEqual(
            capturedRoutes,
            [.productDetails(.productDetails(.deepLink(handle: "silk-shirt", sku: nil, variantId: "variant-9")))]
        )
    }

    func test_didSelectLine_withNoSlug_goesNowhereRatherThanToADeadHandle() {
        // A cart can outlive the product on it, and the BFF sends the line either way. Navigating
        // on an empty handle would land the shopper on a product page that can never resolve.
        let line = CartLine.fixture(id: "line-1", slug: nil)

        sut.didSelectLine(line)

        XCTAssertEqual(capturedRoutes, [])
    }

    // MARK: - Helpers

    /// Puts the view model into `.success` holding `cart`.
    private func showCart(_ cart: Cart) {
        mockCartService.onFetchCalled = { cart }
        XCTAssertEmitsValue(from: sut.$state, where: { $0.isSuccess }, afterTrigger: { self.sut.viewDidAppear() })
    }
}
