import AlicerceLogging
import Mocks
import TestUtils
import XCTest
@testable import AppFeature

/// The sign-out → discard-cart wiring, which lives in `AppFeatureViewModel` because it is app-graph
/// policy rather than anything a single screen owns. Held here so the two things it turns on — that
/// a sign-out reaches the cart, and that a cold launch does not — cannot be broken silently.
final class SignOutDiscardsCartTests: XCTestCase {
    private var sut: AppFeatureViewModel!
    private var cartService: MockCartService!
    private var sessionService: MockSessionService!
    private var spawnedWork: SpawnedWork!
    private var discardCount: Int!

    override func setUpWithError() throws {
        try super.setUpWithError()
        cartService = .init()
        sessionService = .init()
        spawnedWork = .init()
        discardCount = 0
        cartService.onDiscardCartCalled = { [unowned self] in self.discardCount += 1 }
    }

    override func tearDownWithError() throws {
        sut = nil
        cartService = nil
        sessionService = nil
        spawnedWork = nil
        discardCount = nil
        try super.tearDownWithError()
    }

    func test_signing_out_discards_the_cart() async {
        makeSUT()
        sessionService.signInUser()

        sessionService.signOutUser()
        await spawnedWork.run()

        XCTAssertEqual(discardCount, 1)
    }

    /// The publisher replays its current value on subscribe, and that value is "signed out" on every
    /// cold launch. Without the `dropFirst` this test pins, the bag would be emptied before it was
    /// ever shown — a shopper who added something, killed the app and came back would find it gone.
    func test_launching_signed_out_leaves_the_cart_alone() async {
        makeSUT()
        await spawnedWork.run()

        XCTAssertEqual(discardCount, 0)
    }

    /// Signing in must not take the bag away either — a guest cart carries over into the session.
    func test_signing_in_leaves_the_cart_alone() async {
        makeSUT()

        sessionService.signInUser()
        await spawnedWork.run()

        XCTAssertEqual(discardCount, 0)
    }

    // MARK: - Helpers

    private func makeSUT() {
        sut = AppFeatureViewModel(
            serviceProvider: MockServiceProvider(
                cartService: cartService,
                sessionService: sessionService
            ),
            log: Log.DummyLogger(),
            startupCompletionDelay: 0,
            spawn: spawnedWork.spawn
        )
    }
}
