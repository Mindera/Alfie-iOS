import Apollo
import BFFGraph
import Foundation
import Model

final class BFFOperationExecutor {
    private static let graphqlRateLimitedCodes: Set<String> = ["RATE_LIMITED", "THROTTLED"]

    private let apolloClient: ApolloClient
    private let errorReporter: BFFErrorReporterProtocol?

    init(apolloClient: ApolloClient, errorReporter: BFFErrorReporterProtocol?) {
        self.apolloClient = apolloClient
        self.errorReporter = errorReporter
    }

    /// `mapError` re-labels a failure in terms only the calling operation knows — what a GraphQL
    /// status means depends on what was asked for. It defaults to identity, so an operation with
    /// nothing to add passes failures through untouched.
    func fetch<Query: GraphQLQuery>(
        _ query: Query,
        cachePolicy: CachePolicy = .default,
        mapError: (BFFRequestError) -> BFFRequestError = { $0 }
    ) async throws -> Query.Data {
        try await execute(operationName: Query.operationName, mapError: mapError) { [apolloClient] resultHandler in
            apolloClient.fetch(query: query, cachePolicy: cachePolicy, resultHandler: resultHandler)
        }
    }

    /// `mapError` as in `fetch(_:cachePolicy:mapError:)`.
    func perform<Mutation: GraphQLMutation>(
        _ mutation: Mutation,
        mapError: (BFFRequestError) -> BFFRequestError = { $0 }
    ) async throws -> Mutation.Data {
        try await execute(operationName: Mutation.operationName, mapError: mapError) { [apolloClient] resultHandler in
            apolloClient.perform(mutation: mutation, resultHandler: resultHandler)
        }
    }

    // MARK: - Private

    private func execute<Data: RootSelectionSet>(
        operationName: String,
        mapError: (BFFRequestError) -> BFFRequestError,
        start: @escaping (@escaping (Result<GraphQLResult<Data>, Error>) -> Void) -> Cancellable
    ) async throws -> Data {
        try Task.checkCancellation()

        // Capture Apollo's `Cancellable` in a thread-safe box so the cancellation
        // handler can abort the in-flight request if the caller's task is cancelled
        // (e.g. user backs out of PLP mid-fetch). Without this we'd leak a network
        // round-trip and silently drop the response.
        let box = CancellableBox()
        do {
            return try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
                    box.setResumeOnCancel { continuation.resume(throwing: CancellationError()) }
                    let cancellable = start { result in
                        box.resumeOnce { continuation.resume(with: Self.outcome(of: result)) }
                    }
                    box.set(cancellable)
                }
            } onCancel: {
                box.cancel()
            }
        } catch let error as BFFRequestError {
            // Mapped before reporting rather than by the caller afterwards: the reporter decides
            // what reaches Crashlytics from the error's type, so an operation that re-labels its own
            // failures has to do it first or the reporter judges a type nobody ends up seeing. An
            // expired cart is a routine empty state, and reporting it as `.generic` filed a
            // non-fatal for it every time.
            let error = mapError(error)
            reportError(error, operationName: operationName)
            throw error
        }
    }

    private func reportError(_ error: BFFRequestError, operationName: String) {
        guard let reporter = errorReporter else { return }
        let httpStatus: Int? = {
            switch error.type {
            case .serverError(let status):
                return status

            default:
                return nil
            }
        }()
        reporter.report(
            error: error,
            operationName: operationName,
            httpStatus: httpStatus,
            graphqlErrorCode: error.graphqlErrorCode
        )
    }

    private static func outcome<Data: RootSelectionSet>(
        of result: Result<GraphQLResult<Data>, Error>
    ) -> Result<Data, BFFRequestError> {
        switch result {
        case .success(let response):
            if let errors = response.errors, !errors.isEmpty {
                return .failure(requestError(from: errors))
            }
            guard let data = response.data else {
                return .failure(BFFRequestError(type: .generic))
            }
            return .success(data)

        case .failure(let error):
            if let bffError = error as? BFFRequestError { return .failure(bffError) }
            if let urlError = error as? URLError, urlError.code == .timedOut {
                return .failure(BFFRequestError(type: .timeout, error: error))
            }
            return .failure(BFFRequestError(type: .generic, error: error))
        }
    }

    private static func requestError(from errors: [GraphQLError]) -> BFFRequestError {
        let code = errors.first?.extensions?["code"] as? String
        // Carried on every failure but interpreted by nobody here: what a status means depends
        // on the operation, so the cart operations map their own 404 (see `mappingCartNotFound`).
        let status = errors.first?.extensions?["status"] as? Int
        let message = errors.first?.message
        let type: BFFRequestError.BFFRequestErrorType = {
            if let code, graphqlRateLimitedCodes.contains(code) {
                return .rateLimited(retryAfter: nil)
            }
            return .generic
        }()
        return BFFRequestError(type: type, message: message, graphqlErrorCode: code, graphqlErrorStatus: status)
    }
}
