import Apollo
import ApolloAPI
import BFFGraph
import Foundation
import Model

/// Retries transient HTTP failures (5xx, 429, 430) with exponential backoff.
/// Placed after `NetworkFetchInterceptor`/`ResponseLogInterceptor` so it can inspect
/// `HTTPResponse.httpResponse.statusCode` before `ResponseCodeInterceptor` throws.
///
/// Apollo v1.19 routes transport `URLError`s through `chain.handleErrorAsync` from
/// `NetworkFetchInterceptor`, which bypasses subsequent interceptors — so this class
/// only retries HTTP-status-based failures. Transport timeouts are typed as `.timeout`
/// in `BFFClientService.resultAsFailure` and rely on user-tap retry.
final class BackoffRetryInterceptor: ApolloInterceptor {
    struct Configuration {
        var baseDelay: TimeInterval = 0.5
        var multiplier: Double = 2.0
        var maxRetries: Int = 3
        var perAttemptCap: TimeInterval = 8
        var retryAfterCap: TimeInterval = 30
    }

    var id: String = UUID().uuidString

    // Per-operation state. `NetworkInterceptorProvider.interceptors(for:)` constructs
    // a fresh instance per operation; never share an instance across operations or
    // this counter will leak between requests.
    private var retryCount: Int = 0
    private let configuration: Configuration

    init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }

    func interceptAsync<Operation: GraphQLOperation>(
        chain: any RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) {
        // Never retry non-idempotent operations.
        guard Operation.operationType == .query else {
            chain.proceedAsync(request: request, response: response, interceptor: self, completion: completion)
            return
        }

        guard let statusCode = response?.httpResponse.statusCode,
              let decision = retryDecision(for: statusCode, response: response)
        else {
            chain.proceedAsync(request: request, response: response, interceptor: self, completion: completion)
            return
        }

        guard retryCount < configuration.maxRetries else {
            chain.proceedAsync(request: request, response: response, interceptor: self, completion: completion)
            return
        }

        let delay = delayForNextAttempt(retryAfter: decision.retryAfter)
        retryCount += 1

        Task { [weak self, weak chain] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard let chain = chain, chain.isCancelled == false, self != nil else { return }
            chain.retry(request: request, completion: completion)
        }
    }

    // MARK: - Private

    private struct RetryDecision {
        let retryAfter: TimeInterval?
    }

    private func retryDecision<Operation>(
        for statusCode: Int,
        response: HTTPResponse<Operation>?
    ) -> RetryDecision? {
        switch statusCode {
        case 500, 502, 503, 504:
            return RetryDecision(retryAfter: nil)
        case 429, 430:
            let retryAfter = response.flatMap { RetryAfterParser.parse(headerValue: $0.httpResponse.value(forHTTPHeaderField: "Retry-After")) }
            // Beyond cap → don't retry; let RateLimitMappingInterceptor surface .rateLimited.
            if let retryAfter, retryAfter > configuration.retryAfterCap { return nil }
            return RetryDecision(retryAfter: retryAfter)
        default:
            return nil
        }
    }

    private func delayForNextAttempt(retryAfter: TimeInterval?) -> TimeInterval {
        if let retryAfter { return retryAfter }
        let computed = configuration.baseDelay * pow(configuration.multiplier, Double(retryCount))
        return min(computed, configuration.perAttemptCap)
    }
}
