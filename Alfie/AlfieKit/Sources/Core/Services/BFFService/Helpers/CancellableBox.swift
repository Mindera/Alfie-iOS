import Apollo
import Foundation

/// Thread-safe box that lets `withTaskCancellationHandler`'s `onCancel` closure call
/// `cancel()` on an Apollo `Cancellable` produced inside the continuation closure.
///
/// The two callbacks can fire on different threads — and the cancel can fire before
/// the continuation has finished setting up — so the box serialises access with a lock.
/// Calling `cancel()` clears the held reference, making subsequent `cancel()` calls
/// no-ops.
final class CancellableBox: @unchecked Sendable {
    private let lock = NSLock()
    private var cancellable: (any Apollo.Cancellable)?

    func set(_ cancellable: any Apollo.Cancellable) {
        lock.lock(); defer { lock.unlock() }
        self.cancellable = cancellable
    }

    func cancel() {
        lock.lock(); defer { lock.unlock() }
        cancellable?.cancel()
        cancellable = nil
    }
}
