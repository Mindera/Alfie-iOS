import Apollo
import ApolloAPI
import BFFGraph
@testable import Core
import Foundation
import XCTest

final class BackoffRetryInterceptorTests: XCTestCase {
    private let fastConfig = BackoffRetryInterceptor.Configuration(
        baseDelay: 0.001,
        multiplier: 2.0,
        maxRetries: 3,
        perAttemptCap: 0.05,
        retryAfterCap: 30
    )

    // MARK: - Retry on transient HTTP failures

    func test_retries_on_500() async {
        await assertRetried(forStatus: 500)
    }

    func test_retries_on_502() async {
        await assertRetried(forStatus: 502)
    }

    func test_retries_on_503() async {
        await assertRetried(forStatus: 503)
    }

    func test_retries_on_504() async {
        await assertRetried(forStatus: 504)
    }

    func test_retries_on_429() async {
        await assertRetried(forStatus: 429)
    }

    func test_retries_on_430() async {
        await assertRetried(forStatus: 430)
    }

    // MARK: - No retry on non-transient responses

    func test_does_not_retry_on_200() async {
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: fastConfig)

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: InterceptorTestHelpers.makeResponse(status: 200),
            completion: { _ in }
        )

        await Task.yield()
        XCTAssertEqual(chain.retryCount, 0)
        XCTAssertEqual(chain.proceedCount, 1)
    }

    func test_does_not_retry_on_404() async {
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: fastConfig)

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: InterceptorTestHelpers.makeResponse(status: 404),
            completion: { _ in }
        )

        await Task.yield()
        XCTAssertEqual(chain.retryCount, 0)
        XCTAssertEqual(chain.proceedCount, 1)
    }

    func test_does_not_retry_on_501() async {
        // 501 Not Implemented is permanent; must not retry.
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: fastConfig)

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: InterceptorTestHelpers.makeResponse(status: 501),
            completion: { _ in }
        )

        await Task.yield()
        XCTAssertEqual(chain.retryCount, 0)
        XCTAssertEqual(chain.proceedCount, 1)
    }

    // MARK: - Retry exhaustion

    func test_proceeds_after_exhausting_max_retries() async throws {
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: fastConfig)
        let request = InterceptorTestHelpers.makeRequest()
        let response = InterceptorTestHelpers.makeResponse(status: 503)

        for _ in 0..<fastConfig.maxRetries {
            interceptor.interceptAsync(chain: chain, request: request, response: response, completion: { _ in })
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms — ample for fastConfig waits
        }

        // One more pass — should proceed without retrying further.
        interceptor.interceptAsync(chain: chain, request: request, response: response, completion: { _ in })
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(chain.retryCount, fastConfig.maxRetries, "Should retry exactly maxRetries times")
        XCTAssertEqual(chain.proceedCount, 1, "After exhaustion, must proceed so downstream can map the error")
    }

    // MARK: - Retry-After handling

    func test_does_not_retry_when_retry_after_exceeds_cap() async throws {
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: fastConfig)
        let response = InterceptorTestHelpers.makeResponse(status: 429, headers: ["Retry-After": "60"])

        interceptor.interceptAsync(chain: chain, request: InterceptorTestHelpers.makeRequest(), response: response, completion: { _ in })
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(chain.retryCount, 0, "Retry-After of 60s exceeds 30s cap — must not retry")
        XCTAssertEqual(chain.proceedCount, 1, "Must proceed so RateLimitMappingInterceptor can surface .rateLimited")
    }

    func test_retries_when_retry_after_within_cap() async throws {
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: fastConfig)
        let response = InterceptorTestHelpers.makeResponse(status: 429, headers: ["Retry-After": "0"])

        interceptor.interceptAsync(chain: chain, request: InterceptorTestHelpers.makeRequest(), response: response, completion: { _ in })
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(chain.retryCount, 1)
    }

    // MARK: - APQ passthrough

    func test_apq_persisted_query_not_found_is_not_retried() async throws {
        // APQ surfaces 'PersistedQueryNotFound' as HTTP 200 with a GraphQL error code.
        // BackoffRetryInterceptor's status-based logic naturally skips this — verify.
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: fastConfig)

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: InterceptorTestHelpers.makeResponse(status: 200),
            completion: { _ in }
        )
        try await Task.sleep(nanoseconds: 10_000_000)

        XCTAssertEqual(chain.retryCount, 0)
        XCTAssertEqual(chain.proceedCount, 1)
    }

    // MARK: - Helpers

    private func assertRetried(forStatus status: Int, file: StaticString = #file, line: UInt = #line) async {
        let chain = MockRequestChain()
        let interceptor = BackoffRetryInterceptor(configuration: fastConfig)

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: InterceptorTestHelpers.makeResponse(status: status),
            completion: { _ in }
        )

        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms — ample for first backoff under fastConfig
        XCTAssertEqual(chain.retryCount, 1, "Status \(status) should trigger one retry", file: file, line: line)
        XCTAssertEqual(chain.proceedCount, 0, "Status \(status) should not call proceed before retry", file: file, line: line)
    }
}
