import AlicerceLogging
import Mocks
import Model
import TestUtils
import XCTest
@testable import AppFeature

/// The cart → badge subscription in `RootTabViewModel`, and the launch read that gives it something
/// to publish. Nothing else covers either: `BagBadgeTests` pins which number is computed and the
/// snapshots pin where it is drawn, but only these fail if the badge stops being *live* — delete the
/// `.store(in:)` and every other test in the suite still passes.
///
/// Driven through `AppFeatureViewModel` rather than by constructing `RootTabViewModel` and its five
/// flow view models by hand: that is how the app builds the graph, and how `AppStartupServiceTests`
/// already reaches it.
final class BagBadgeWiringTests: XCTestCase {
    private var cartService: MockCartService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        cartService = .init()
    }

    override func tearDownWithError() throws {
        cartService = nil
        try super.tearDownWithError()
    }

    func test_cartWithLines_summedQuantityReachesTheBadge() {
        let sut = makeSut()

        XCTAssertEmitsValueEqualTo(
            from: sut.rootTabViewModel.$bagBadgeValue,
            expectedValue: 7,
            afterTrigger: {
                self.publish(.fixture(lines: [
                    .fixture(id: "line-1", quantity: 3),
                    .fixture(id: "line-2", quantity: 4),
                ]))
            }
        )
    }

    /// Removing the last line has to take the badge away with it, not leave a stale count behind.
    /// `dropFirst` because `@Published` replays its current value on subscribe, and that value is
    /// already `nil` — without it the assertion would pass before the cart was ever emptied.
    func test_emptyingTheCart_clearsTheBadge() {
        let sut = makeSut()

        XCTAssertEmitsValueEqualTo(
            from: sut.rootTabViewModel.$bagBadgeValue,
            expectedValue: 3,
            afterTrigger: { self.publish(.fixture(lines: [.fixture(quantity: 3)])) }
        )

        XCTAssertEmitsValueEqualTo(
            from: sut.rootTabViewModel.$bagBadgeValue.dropFirst(),
            expectedValue: Int?.none,
            afterTrigger: { self.publish(.fixture(lines: [])) }
        )
    }

    /// The gap a shopper actually hits: add items, kill the app, come back. The cart id survives in
    /// `UserDefaults` but the cart does not, so the badge is only right at launch if something reads
    /// it back — and the bag screen's own fetch is too late, it only runs once they open the bag.
    func test_launching_readsTheStoredCartSoTheBadgeIsRightBeforeTheBagIsOpened() {
        cartService.onFetchCalled = { .fixture(lines: [.fixture(quantity: 2)]) }

        let sut = makeSut()

        XCTAssertEmitsValueEqualTo(from: sut.rootTabViewModel.$bagBadgeValue, expectedValue: 2)
    }

    // MARK: - Helpers

    private func makeSut() -> AppFeatureViewModel {
        AppFeatureViewModel(
            serviceProvider: MockServiceProvider(cartService: cartService),
            log: Log.DummyLogger(),
            startupCompletionDelay: 0
        )
    }

    /// The cart service is the only thing that publishes a cart, so a test moves the badge the same
    /// way the app does — through a fetch — rather than by poking the view model.
    private func publish(_ cart: Cart) {
        cartService.onFetchCalled = { cart }
        Task { try? await self.cartService.fetch() }
    }
}
