import Apollo
import ApolloAPI
import Foundation

/// Minimal in-memory `RequestChain` for interceptor unit tests. Records which chain
/// method was invoked and how many times so a test can assert on interceptor behaviour
/// without spinning up a real `InterceptorRequestChain`.
final class MockRequestChain: RequestChain, @unchecked Sendable {
    private let lock = NSLock()
    private var _proceedCount: Int = 0
    private var _retryCount: Int = 0
    private var _handleErrorCount: Int = 0
    private var _capturedError: (any Error)?
    private var _isCancelled: Bool = false

    var proceedCount: Int { withLock { _proceedCount } }
    var retryCount: Int { withLock { _retryCount } }
    var handleErrorCount: Int { withLock { _handleErrorCount } }
    var capturedError: (any Error)? { withLock { _capturedError } }

    var isCancelled: Bool {
        get { withLock { _isCancelled } }
    }

    func setCancelled(_ value: Bool) {
        withLock { _isCancelled = value }
    }

    func cancel() {
        withLock { _isCancelled = true }
    }

    func kickoff<Operation>(request: HTTPRequest<Operation>, completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void) where Operation: GraphQLOperation {}

    func proceedAsync<Operation>(request: HTTPRequest<Operation>, response: HTTPResponse<Operation>?, completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void) where Operation: GraphQLOperation {
        withLock { _proceedCount += 1 }
    }

    func proceedAsync<Operation>(request: HTTPRequest<Operation>, response: HTTPResponse<Operation>?, interceptor: any ApolloInterceptor, completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void) where Operation: GraphQLOperation {
        withLock { _proceedCount += 1 }
    }

    func retry<Operation>(request: HTTPRequest<Operation>, completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void) where Operation: GraphQLOperation {
        withLock { _retryCount += 1 }
    }

    func handleErrorAsync<Operation>(_ error: any Error, request: HTTPRequest<Operation>, response: HTTPResponse<Operation>?, completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void) where Operation: GraphQLOperation {
        withLock {
            _handleErrorCount += 1
            _capturedError = error
        }
    }

    func returnValueAsync<Operation>(for request: HTTPRequest<Operation>, value: GraphQLResult<Operation.Data>, completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void) where Operation: GraphQLOperation {}

    private func withLock<T>(_ block: () -> T) -> T {
        lock.lock(); defer { lock.unlock() }
        return block()
    }
}
