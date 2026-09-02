import AlicerceLogging
import Apollo
import ApolloAPI
import BFFGraph
@testable import Core
import Foundation
import Mocks
import XCTest

/// Mutations are not idempotent: a retried `addToCart` adds the line twice, and a cached one hands
/// a later read a stale cart. Both exclusions are asserted here, alongside the query chain that
/// must keep them.
final class MutationInterceptorChainTests: XCTestCase {
    // MARK: - Retry

    func test_a_transient_failure_on_a_mutation_is_not_retried_so_an_add_cannot_double_add() {
        let chain = MockRequestChain()
        let interceptor = RetryInterceptor()

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeMutationRequest(),
            response: InterceptorTestHelpers.makeMutationResponse(status: 503),
            completion: { _ in }
        )

        XCTAssertEqual(chain.retryCount, 0, "A retried addToCart would add the same line twice")
        XCTAssertEqual(chain.proceedCount, 1, "The failure must still travel down the chain")
    }

    func test_the_same_transient_failure_on_a_query_is_retried() {
        // Guards the exclusion above from over-reaching: queries keep their retries.
        let chain = MockRequestChain()
        let interceptor = RetryInterceptor(configuration: .init(scheduleRetry: { _, work in work() }))

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: InterceptorTestHelpers.makeResponse(status: 503),
            completion: { _ in }
        )

        XCTAssertEqual(chain.retryCount, 1)
    }

    // MARK: - Cache

    func test_a_mutation_chain_omits_cache_read_and_write() {
        let chain = makeProvider().interceptors(for: BFFGraphAPI.AddToCartMutation(
            input: BFFGraphAPI.AddToCartInput(cartId: "cart-1", lines: [])
        ))

        XCTAssertFalse(
            chain.contains { $0 is CacheReadInterceptor },
            "A cached cart would be served in place of the freshly mutated one"
        )
        XCTAssertFalse(
            chain.contains { $0 is CacheWriteInterceptor },
            "Writing the mutation result normalises a Cart into the same cache a query reads"
        )
    }

    func test_a_query_chain_keeps_cache_read_and_write() {
        // Deliberately a query the app really does cache. `CartQuery` also keeps both interceptors
        // — the chain gates on operation type, not cache policy — but `getCart` issues it with
        // `.fetchIgnoringCacheCompletely`, so it would prove the rule with an inert example.
        let chain = makeProvider().interceptors(for: BFFGraphAPI.ProductListQuery(
            collectionHandle: "test",
            after: .none,
            limit: 1,
            filters: .none
        ))

        XCTAssertTrue(chain.contains { $0 is CacheReadInterceptor })
        XCTAssertTrue(chain.contains { $0 is CacheWriteInterceptor })
    }

    // MARK: - Helpers

    private func makeProvider() -> NetworkInterceptorProvider {
        NetworkInterceptorProvider(
            client: URLSessionClient(),
            store: ApolloStore(cache: InMemoryNormalizedCache()),
            reachabilityService: MockReachabilityService(),
            logRequests: false,
            log: Log.DummyLogger()
        )
    }
}
