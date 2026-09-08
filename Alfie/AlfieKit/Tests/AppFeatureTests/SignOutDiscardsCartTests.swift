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

    override func setUpWithError() throws {
        try super.setUpWithError()
        cartService = .init()
        sessionService = .init()
    }

    override func tearDownWithError() throws {
        sut = nil
        cartService = nil
        sessionService = nil
        try super.tearDownWithError()
    }

    func test_signingOut_discardsTheCart() {
        let discarded = expectation(description: "the sign-out reaches the cart")
        cartService.onDiscardCartCalled = { discarded.fulfill() }
        makeSUT()
        sessionService.signInUser()

        sessionService.signOutUser()

        wait(for: [discarded], timeout: 1)
    }

    /// The publisher replays its current value on subscribe, and that value is "signed out" on every
    /// cold launch. Without the `dropFirst` this test pins, the bag would be emptied before it was
    /// ever shown — a shopper who added something, killed the app and came back would find it gone.
    func test_launchingSignedOut_leavesTheCartAlone() {
        let discarded = notDiscarded()

        makeSUT()

        wait(for: [discarded], timeout: 0.2)
    }

    /// Signing in must not take the bag away either — a guest cart carries over into the session.
    func test_signingIn_leavesTheCartAlone() {
        let discarded = notDiscarded()
        makeSUT()

        sessionService.signInUser()

        wait(for: [discarded], timeout: 0.2)
    }

    // MARK: - Helpers

    /// Built here rather than in `setUp` so a test can install its expectation before the graph
    /// subscribes. Constructing the SUT first would leave the negative tests unable to fail: the
    /// discard they forbid could land in the gap before the callback was set.
    private func makeSUT() {
        sut = AppFeatureViewModel(
            serviceProvider: MockServiceProvider(
                cartService: cartService,
                sessionService: sessionService
            ),
            log: Log.DummyLogger(),
            startupCompletionDelay: 0
        )
    }

    /// An inverted expectation, so a discard that should not happen is given every chance to happen
    /// anyway and fails the test when it does. A plain assertion made after the fact would run
    /// before the `Task` behind `discardCart()` had a chance to, and so would never fail.
    private func notDiscarded() -> XCTestExpectation {
        let discarded = expectation(description: "the cart is left alone")
        discarded.isInverted = true
        cartService.onDiscardCartCalled = { discarded.fulfill() }
        return discarded
    }
}
