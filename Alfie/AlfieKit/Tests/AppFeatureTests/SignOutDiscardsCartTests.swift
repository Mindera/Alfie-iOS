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
        sut = AppFeatureViewModel(
            serviceProvider: MockServiceProvider(
                cartService: cartService,
                sessionService: sessionService
            ),
            log: Log.DummyLogger(),
            startupCompletionDelay: 0
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        cartService = nil
        sessionService = nil
        try super.tearDownWithError()
    }

    func test_signingOut_discardsTheCart() {
        sessionService.signInUser()

        sessionService.signOutUser()

        wait(for: self.cartService.discardCartCount == 1, "A sign-out must discard the cart")
    }

    /// The publisher replays its current value on subscribe, and that value is "signed out" on every
    /// cold launch. Without the `dropFirst` this test pins, the bag would be emptied before it was
    /// ever shown — a shopper who added something, killed the app and came back would find it gone.
    func test_launchingSignedOut_leavesTheCartAlone() {
        settle()

        XCTAssertEqual(cartService.discardCartCount, 0, "Starting up signed out is not a sign-out")
    }

    /// Signing in must not take the bag away either — a guest cart carries over into the session.
    func test_signingIn_leavesTheCartAlone() {
        sessionService.signInUser()
        settle()

        XCTAssertEqual(cartService.discardCartCount, 0, "Signing in is not a sign-out")
    }

    // MARK: - Helpers

    /// `discardCart` is reached through a `Task`, so the assertion has to outlast a hop off this
    /// thread. Polls rather than sleeping a fixed interval, so the passing case stays fast.
    private func wait(
        for condition: @autoclosure @escaping () -> Bool,
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let deadline = Date().addingTimeInterval(1)
        while !condition(), Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }
        XCTAssertTrue(condition(), message, file: file, line: line)
    }

    /// Gives a discard that should *not* happen every chance to happen anyway. A negative assertion
    /// made without this would pass before the `Task` had a chance to run, and so would never fail.
    private func settle() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.2))
    }
}
