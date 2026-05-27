import Apollo
import ApolloAPI
import BFFGraph
import Foundation
import Model

/// Retries transient HTTP failures (5xx, 429, 430) with exponential backoff, then
/// surfaces a typed `BFFRequestError` carrying the final status + observed retry
/// count when retries are exhausted or declined.
///
/// Placed after `NetworkFetchInterceptor`/`ResponseLogInterceptor` so it can inspect
/// `HTTPResponse.httpResponse.statusCode` before `ResponseCodeInterceptor` throws.
///
/// Apollo v1.19 routes transport `URLError`s through `chain.handleErrorAsync` from
/// `NetworkFetchInterceptor`, which bypasses subsequent interceptors — so this class
/// only retries HTTP-status-based failures. Transport timeouts are typed as `.timeout`
/// in `BFFClientService.resultAsFailure` and rely on user-tap retry.
final class RetryInterceptor: ApolloInterceptor {
    struct Configuration {
        var baseDelay: TimeInterval = 0.5
        var multiplier: Double = 2.0
        var maxRetries: Int = 3
        var perAttemptCap: TimeInterval = 8
        var retryAfterCap: TimeInterval = 30
        /// Schedules `work` to run after `delay`. Overridable for deterministic tests
        /// (pass `{ _, work in work() }` to fire synchronously).
        var scheduleRetry: @Sendable (_ delay: TimeInterval, _ work: @escaping @Sendable () -> Void) -> Void = { delay, work in
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay, execute: work)
        }

        /// Buffer added to `maxRetries` when sizing Apollo's `MaxRetryInterceptor` safety
        /// cap. Larger than 0 so a single off-by-one in retry accounting can't trip the
        /// cap before this interceptor's own give-up logic runs.
        static let safetyCapBuffer: Int = 2

        /// Apollo `MaxRetryInterceptor.maxRetriesAllowed` value that pairs with this
        /// configuration. Use at the call site so the chain's safety cap auto-tracks
        /// whatever `maxRetries` is configured to.
        var chainSafetyCap: Int { maxRetries + Self.safetyCapBuffer }
    }

    var id: String = UUID().uuidString

    // Per-operation state. `NetworkInterceptorProvider.interceptors(for:)` constructs
    // a fresh instance per operation; never share across operations or this counter
    // will leak between requests. Mutated only on Apollo's processing queue.
    private var retryCount: Int = 0
    let configuration: Configuration

    init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }

    func interceptAsync<Operation: GraphQLOperation>(
        chain: any RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) {
        // Never retry non-idempotent operations, and only act on completed responses
        // that carry a status code we care about.
        guard Operation.operationType == .query,
              let statusCode = response?.httpResponse.statusCode,
              let kind = TransientFailureKind(statusCode: statusCode)
        else {
            chain.proceedAsync(request: request, response: response, interceptor: self, completion: completion)
            return
        }

        let retryAfter: TimeInterval? = (kind == .rateLimit)
            ? RetryAfterParser.parse(headerValue: response?.httpResponse.value(forHTTPHeaderField: "Retry-After"))
            : nil

        let withinRetryBudget = retryCount < configuration.maxRetries
        let retryAfterFits = retryAfter.map { $0 <= configuration.retryAfterCap } ?? true

        guard withinRetryBudget, retryAfterFits else {
            // Give up — surface a typed BFFRequestError carrying the observed retry
            // count so downstream telemetry can record it.
            let typedError = BFFRequestError(
                type: kind.toErrorType(statusCode: statusCode, retryAfter: retryAfter),
                retryCount: retryCount
            )
            chain.handleErrorAsync(typedError, request: request, response: response, completion: completion)
            return
        }

        let delay = retryAfter ?? exponentialDelay()
        retryCount += 1

        configuration.scheduleRetry(delay) { [weak chain] in
            guard let chain, !chain.isCancelled else {
                // Caller cancelled mid-backoff. Fail the continuation explicitly
                // rather than letting it hang until the URLSession resource timeout.
                completion(.failure(URLError(.cancelled)))
                return
            }
            chain.retry(request: request, completion: completion)
        }
    }

    private func exponentialDelay() -> TimeInterval {
        let computed = configuration.baseDelay * pow(configuration.multiplier, Double(retryCount))
        return min(computed, configuration.perAttemptCap)
    }
}

// MARK: - Transient failure classification

private enum TransientFailureKind {
    case server      // 5xx subset we treat as transient
    case rateLimit   // 429 / 430

    init?(statusCode: Int) {
        switch statusCode {
        case 500, 502, 503, 504: self = .server
        case 429, 430: self = .rateLimit
        default: return nil
        }
    }

    func toErrorType(statusCode: Int, retryAfter: TimeInterval?) -> BFFRequestError.BFFRequestErrorType {
        switch self {
        case .server: return .serverError(status: statusCode)
        case .rateLimit: return .rateLimited(retryAfter: retryAfter)
        }
    }
}
