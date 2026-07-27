import Apollo
import Foundation

/// Thread-safe box bridging an Apollo `Cancellable` (produced inside a continuation closure) to
/// `withTaskCancellationHandler`'s `onCancel`.
///
/// Beyond cancelling the in-flight request, it guarantees the continuation is resumed **exactly
/// once**: Apollo's request chain does NOT invoke its result handler after `cancel()`, so without
/// this the continuation would leak and the awaiting task would hang forever. Whichever fires
/// first — the Apollo result or the cancellation — resumes; the other becomes a no-op. The two can
/// arrive on different threads, so access is serialised with a lock.
final class CancellableBox: @unchecked Sendable {
    private let lock = NSLock()
    private var cancellable: (any Apollo.Cancellable)?
    private var hasResumed = false
    private var resumeOnCancel: (@Sendable () -> Void)?
    private var cancelledBeforeResumeSet = false

    /// Store how to resume the continuation with cancellation. Called once, at the start of the
    /// continuation body. If cancellation already fired in the race window before this ran (task
    /// cancelled between entering `withTaskCancellationHandler` and this line), resume immediately
    /// — otherwise `cancel()` had no closure to call and the continuation would hang forever.
    func setResumeOnCancel(_ resume: @escaping @Sendable () -> Void) {
        lock.lock()
        guard !cancelledBeforeResumeSet else {
            // `cancel()` already set `hasResumed`, so the Apollo callback will no-op — this is the
            // one and only resume.
            lock.unlock()
            resume()
            return
        }
        resumeOnCancel = resume
        lock.unlock()
    }

    func set(_ cancellable: any Apollo.Cancellable) {
        lock.lock()
        // Lost the race to a cancel that already fired — cancel this straggler instead of holding it.
        guard !hasResumed else {
            lock.unlock()
            cancellable.cancel()
            return
        }
        self.cancellable = cancellable
        lock.unlock()
    }

    /// Resume from the Apollo result path. Runs `resume` only if nothing has resumed yet.
    func resumeOnce(_ resume: () -> Void) {
        lock.lock()
        guard !hasResumed else { lock.unlock(); return }
        hasResumed = true
        lock.unlock()
        resume()
    }

    /// Cancel the in-flight request and, if it hadn't resumed yet, resume the continuation with
    /// cancellation so the awaiting task doesn't hang.
    func cancel() {
        lock.lock()
        cancellable?.cancel()
        cancellable = nil
        let shouldResume = !hasResumed
        hasResumed = true
        let resume = resumeOnCancel
        if shouldResume, resume == nil {
            // Lost the race with `setResumeOnCancel` — mark it so that call resumes the continuation.
            cancelledBeforeResumeSet = true
        }
        lock.unlock()
        if shouldResume {
            resume?()
        }
    }
}
