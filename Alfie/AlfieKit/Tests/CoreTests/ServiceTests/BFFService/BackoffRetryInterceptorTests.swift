import Apollo
import ApolloAPI
import BFFGraph
@testable import Core
import Foundation
import Model
import XCTest

final class BackoffRetryInterceptorTests: XCTestCase {
    /// Configuration that fires retries synchronously on the calling thread so tests
    /// are race-free and finish in microseconds.
    private func makeConfig(maxRetries: Int = 3, retryAfterCap: TimeInterval = 30) -> BackoffRetryInterceptor.Configuration {
        BackoffRetryInterceptor.Configuration(
            baseDelay: 0.001,
            multiplier: 2.0,
            maxRetries: maxRetries,
            perAttemptCap: 0.05,
            retryAfterCap: retryAfterCap,
            scheduleRetry: { _, work in work() }
        )
    }

    // MARK: - Retry on transient HTTP failures

    func test_retries_on_transient_statuses() {
        for status in [500, 502, 503, 504, 429, 430] {
            let chain = MockRequestChain()
            let interceptor = BackoffRetryInterceptor(configuration: makeConfig())

            interceptor.interceptAsync(
                chain: chain,
                request: InterceptorTestHelpers.makeRequest(),
                response: InterceptorTestHelpers.makeResponse(status: status),
                completion: { _ in }
            )

            XCTAssertEqual(chain.retryCount, 1, "Status \(status) should trigger one retry")
            XCTAssertEqual(chain.proceedCount, 0, "Status \(status) should not call proceed before retry")
            XCTAssertEqual(chain.handleErrorCount, 0, "Status \(status) should not surface an error on first attempt")
        }
    }

    // MARK: - No retry on non-transient responses

    func test_does_not_retry_on_non_transient_statuses() {
        for status in [200, 204, 400, 401, 403, 404, 501, 505] {
            let chain = MockRequestChain()
            let interceptor = BackoffRetryInterceptor(configuration: makeConfig())

            interceptor.interceptAsync(
                chain: chain,
                request: InterceptorTestHelpers.makeRequest(),
                response: InterceptorTestHelpers.makeResponse(status: status),
                completion: { _ in }
            )

            XCTAssertEqual(chain.retryCount, 0, "Status \(status) must not retry")
            XCTAssertEqual(chain.proceedCount, 1, "Status \(status) must proceed downstream")
            XCTAssertEqual(chain.handleErrorCount, 0)
        }
    }

    // MARK: - Retry exhaustion → typed error with retry count

    func test_exhausted_5xx_retries_surface_server_error_with_retry_count() {
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: makeConfig(maxRetries: 3))
        let response = InterceptorTestHelpers.makeResponse(status: 503)

        // Simulate Apollo re-running the chain on each chain.retry() by invoking
        // interceptAsync once per attempt. After maxRetries=3 retries, the next
        // intercept must surface a typed error.
        for _ in 0..<3 {
            interceptor.interceptAsync(chain: chain, request: InterceptorTestHelpers.makeRequest(), response: response, completion: { _ in })
        }
        interceptor.interceptAsync(chain: chain, request: InterceptorTestHelpers.makeRequest(), response: response, completion: { _ in })

        XCTAssertEqual(chain.retryCount, 3)
        XCTAssertEqual(chain.handleErrorCount, 1, "After exhaustion, must surface typed error via handleErrorAsync")
        guard let bff = chain.capturedError as? BFFRequestError,
              case .serverError(let status) = bff.type else {
            XCTFail("Expected .serverError; got \(String(describing: chain.capturedError))")
            return
        }
        XCTAssertEqual(status, 503)
        XCTAssertEqual(bff.retryCount, 3, "Final error must carry the observed retry count for telemetry")
    }

    func test_exhausted_429_retries_surface_rate_limited_with_retry_count() {
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: makeConfig(maxRetries: 2))
        let response = InterceptorTestHelpers.makeResponse(status: 429, headers: ["Retry-After": "1"])

        for _ in 0..<2 {
            interceptor.interceptAsync(chain: chain, request: InterceptorTestHelpers.makeRequest(), response: response, completion: { _ in })
        }
        interceptor.interceptAsync(chain: chain, request: InterceptorTestHelpers.makeRequest(), response: response, completion: { _ in })

        guard let bff = chain.capturedError as? BFFRequestError,
              case .rateLimited(let retryAfter) = bff.type else {
            XCTFail("Expected .rateLimited")
            return
        }
        XCTAssertEqual(retryAfter, 1)
        XCTAssertEqual(bff.retryCount, 2)
    }

    // MARK: - Retry-After handling

    func test_retry_after_exceeding_cap_surfaces_rate_limited_immediately() {
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: makeConfig())
        let response = InterceptorTestHelpers.makeResponse(status: 429, headers: ["Retry-After": "60"])

        interceptor.interceptAsync(chain: chain, request: InterceptorTestHelpers.makeRequest(), response: response, completion: { _ in })

        XCTAssertEqual(chain.retryCount, 0, "Retry-After of 60s exceeds 30s cap — must not retry")
        XCTAssertEqual(chain.handleErrorCount, 1)
        guard let bff = chain.capturedError as? BFFRequestError, case .rateLimited(let retryAfter) = bff.type else {
            XCTFail("Expected .rateLimited")
            return
        }
        XCTAssertEqual(retryAfter, 60)
        XCTAssertEqual(bff.retryCount, 0, "No retries attempted, retryCount must be 0")
    }

    func test_retries_when_retry_after_within_cap() {
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: makeConfig())
        let response = InterceptorTestHelpers.makeResponse(status: 429, headers: ["Retry-After": "5"])

        interceptor.interceptAsync(chain: chain, request: InterceptorTestHelpers.makeRequest(), response: response, completion: { _ in })

        XCTAssertEqual(chain.retryCount, 1)
        XCTAssertEqual(chain.handleErrorCount, 0)
    }

    // MARK: - Cancellation safety

    func test_cancelled_chain_fires_completion_with_url_cancelled_error() {
        let chain = MockRequestChain()
        chain.setCancelled(true)
        let interceptor = BackoffRetryInterceptor(configuration: makeConfig())

        let expectation = XCTestExpectation(description: "completion called on cancelled chain")
        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: InterceptorTestHelpers.makeResponse(status: 503),
            completion: { result in
                if case .failure(let error) = result, (error as? URLError)?.code == .cancelled {
                    expectation.fulfill()
                }
            }
        )

        XCTAssertEqual(chain.retryCount, 0, "Cancelled chain must not retry")
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - No leaked extra retries

    func test_single_intercept_call_triggers_exactly_one_retry() {
        // Regression guard: a bug that scheduled two retries per intercept would
        // pass the basic retry tests above. Use a custom scheduler that runs work
        // synchronously AND counts how many times it was scheduled.
        var scheduleCount = 0
        var config = makeConfig()
        config.scheduleRetry = { _, work in
            scheduleCount += 1
            work()
        }
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: config)

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: InterceptorTestHelpers.makeResponse(status: 503),
            completion: { _ in }
        )

        XCTAssertEqual(scheduleCount, 1, "Each interceptAsync invocation must schedule at most one retry")
        XCTAssertEqual(chain.retryCount, 1)
    }

    // MARK: - Interceptor deinit safety

    func test_deinit_during_pending_retry_does_not_call_completion_after_chain_cancelled() {
        // Capture the work closure so we can fire it after `interceptor` is gone.
        // Apollo only retains the interceptor for the duration of the operation;
        // if it deinits while a backoff is in flight, the spawned work must not
        // crash or fire on a stale chain.
        var pendingWork: (() -> Void)?
        var config = makeConfig()
        config.scheduleRetry = { _, work in pendingWork = work }

        let chain = MockRequestChain()
        do {
            let interceptor = BackoffRetryInterceptor(configuration: config)
            interceptor.interceptAsync(
                chain: chain,
                request: InterceptorTestHelpers.makeRequest(),
                response: InterceptorTestHelpers.makeResponse(status: 503),
                completion: { _ in }
            )
        } // interceptor goes out of scope here

        chain.setCancelled(true)
        // Firing the captured work after interceptor deinit must not crash and must
        // not invoke chain.retry on a cancelled chain.
        pendingWork?()

        XCTAssertEqual(chain.retryCount, 0, "Cancelled chain must not be retried even after deinit")
    }

    // MARK: - APQ passthrough

    func test_apq_persisted_query_not_found_is_not_retried() {
        // APQ surfaces 'PersistedQueryNotFound' as HTTP 200 with a GraphQL error
        // payload — not a 5xx — so the status-based check naturally passes through.
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: makeConfig())

        let body = #"{"errors":[{"message":"PersistedQueryNotFound","extensions":{"code":"PERSISTED_QUERY_NOT_FOUND"}}]}"#
        let response = InterceptorTestHelpers.makeResponse(status: 200, bodyJSON: body)

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: response,
            completion: { _ in }
        )

        XCTAssertEqual(chain.retryCount, 0)
        XCTAssertEqual(chain.proceedCount, 1)
    }
}
