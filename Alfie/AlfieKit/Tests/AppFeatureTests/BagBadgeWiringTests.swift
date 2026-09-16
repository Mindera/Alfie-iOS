import AlicerceLogging
import CombineSchedulers
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

    func test_cart_with_lines_reaches_the_badge_as_a_summed_quantity() async throws {
        let sut = makeSut()

        try await publish(.fixture(lines: [
            .fixture(id: "line-1", quantity: 3),
            .fixture(id: "line-2", quantity: 4),
        ]))

        XCTAssertEqual(sut.rootTabViewModel.bagBadgeValue, 7)
    }

    /// Removing the last line has to take the badge away with it, not leave a stale count behind.
    func test_emptying_the_cart_clears_the_badge() async throws {
        let sut = makeSut()
        try await publish(.fixture(lines: [.fixture(quantity: 3)]))
        XCTAssertEqual(sut.rootTabViewModel.bagBadgeValue, 3)

        try await publish(.fixture(lines: []))

        XCTAssertNil(sut.rootTabViewModel.bagBadgeValue)
    }

    /// The gap a shopper actually hits: add items, kill the app, come back. The cart id survives in
    /// `UserDefaults` but the cart does not, so the badge is only right at launch if something reads
    /// it back — and the bag screen's own fetch is too late, it only runs once they open the bag.
    /// The launch read is a `Task` the graph owns, so this one waits on the publisher rather than
    /// driving the fetch itself — and keeps the real scheduler, since the hop is part of what it
    /// pins. `.immediate` would land the value before the wait could subscribe to see it.
    func test_launching_reads_the_stored_cart_so_the_badge_is_right_before_the_bag_is_opened() {
        cartService.onFetchCalled = { .fixture(lines: [.fixture(quantity: 2)]) }

        let sut = makeSut(scheduler: .main)

        XCTAssertEmitsValueEqualTo(from: sut.rootTabViewModel.$bagBadgeValue, expectedValue: 2)
    }

    // MARK: - Helpers

    /// `.immediate` so the badge lands with the cart emission instead of a main-queue hop later: the
    /// hop is what made the assertions race the scheduler on a loaded CI runner.
    private func makeSut(scheduler: AnySchedulerOf<DispatchQueue> = .immediate) -> AppFeatureViewModel {
        AppFeatureViewModel(
            serviceProvider: MockServiceProvider(cartService: cartService),
            log: Log.DummyLogger(),
            startupCompletionDelay: 0,
            scheduler: scheduler
        )
    }

    /// The cart service is the only thing that publishes a cart, so a test moves the badge the same
    /// way the app does — through a fetch — rather than by poking the view model. Awaited, so the
    /// badge is settled by the time the assertion reads it.
    private func publish(_ cart: Cart) async throws {
        cartService.onFetchCalled = { cart }
        try await cartService.fetch()
    }
}
