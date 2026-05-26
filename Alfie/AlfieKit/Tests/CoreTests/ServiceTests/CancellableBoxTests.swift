import Apollo
@testable import Core
import Foundation
import XCTest

final class CancellableBoxTests: XCTestCase {
    func test_cancel_after_set_invokes_the_underlying_cancellable() {
        let spy = SpyCancellable()
        let box = CancellableBox()
        box.set(spy)

        box.cancel()

        XCTAssertEqual(spy.cancelCount, 1)
    }

    func test_cancel_before_set_is_a_noop() {
        let box = CancellableBox()
        // Should not crash.
        box.cancel()
    }

    func test_cancel_clears_the_reference_so_subsequent_cancels_do_nothing() {
        let spy = SpyCancellable()
        let box = CancellableBox()
        box.set(spy)

        box.cancel()
        box.cancel()
        box.cancel()

        XCTAssertEqual(spy.cancelCount, 1, "Second and third cancel() calls must be no-ops")
    }

    func test_setting_a_new_cancellable_after_cancel_starts_a_fresh_cycle() {
        let first = SpyCancellable()
        let second = SpyCancellable()
        let box = CancellableBox()

        box.set(first)
        box.cancel()
        box.set(second)
        box.cancel()

        XCTAssertEqual(first.cancelCount, 1)
        XCTAssertEqual(second.cancelCount, 1)
    }
}

// MARK: - Helpers

private final class SpyCancellable: Apollo.Cancellable, @unchecked Sendable {
    private let lock = NSLock()
    private(set) var cancelCount = 0

    func cancel() {
        lock.lock(); defer { lock.unlock() }
        cancelCount += 1
    }
}
