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

    // MARK: - Continuation resume (exactly-once)

    func test_cancel_after_resume_closure_set_resumes_with_cancellation() {
        let box = CancellableBox()
        let cancelResumes = Counter()
        box.setResumeOnCancel { cancelResumes.increment() }

        box.cancel()

        XCTAssertEqual(cancelResumes.value, 1)
    }

    // Regression (Copilot): the task is cancelled in the window before the continuation body sets
    // its resume closure — `cancel()` runs before `setResumeOnCancel()`. Before the fix the
    // continuation was never resumed and the awaiting task hung forever.
    func test_cancel_before_resume_closure_set_still_resumes_when_set() {
        let box = CancellableBox()
        let cancelResumes = Counter()

        box.cancel() // races ahead of the continuation body — no resume closure stored yet

        box.setResumeOnCancel { cancelResumes.increment() }

        XCTAssertEqual(cancelResumes.value, 1)
    }

    func test_result_resume_wins_and_cancel_is_a_noop() {
        let box = CancellableBox()
        let cancelResumes = Counter()
        let resultResumes = Counter()
        box.setResumeOnCancel { cancelResumes.increment() }

        box.resumeOnce { resultResumes.increment() }
        box.cancel()

        XCTAssertEqual(resultResumes.value, 1)
        XCTAssertEqual(cancelResumes.value, 0)
    }

    func test_cancel_wins_and_a_later_result_is_a_noop() {
        let box = CancellableBox()
        let cancelResumes = Counter()
        let resultResumes = Counter()
        box.setResumeOnCancel { cancelResumes.increment() }

        box.cancel()
        box.resumeOnce { resultResumes.increment() }

        XCTAssertEqual(cancelResumes.value, 1)
        XCTAssertEqual(resultResumes.value, 0)
    }

    func test_repeated_cancel_resumes_exactly_once() {
        let box = CancellableBox()
        let cancelResumes = Counter()
        box.setResumeOnCancel { cancelResumes.increment() }

        box.cancel()
        box.cancel()

        XCTAssertEqual(cancelResumes.value, 1)
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

/// Reference counter so the `@Sendable` resume closures can record how often they ran.
private final class Counter: @unchecked Sendable {
    private(set) var value = 0
    func increment() { value += 1 }
}
