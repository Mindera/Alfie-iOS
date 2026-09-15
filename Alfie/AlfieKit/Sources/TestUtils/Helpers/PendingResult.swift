import Foundation

public final class PendingResult<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Value, Error>?
    private var result: Value?

    public init() {}

    public func value() async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            lock.lock()
            defer { lock.unlock() }
            if let result {
                continuation.resume(returning: result)
            } else {
                self.continuation = continuation
            }
        }
    }

    public func resume(with value: Value) {
        lock.lock()
        defer { lock.unlock() }
        result = value
        continuation?.resume(returning: value)
        continuation = nil
    }
}
