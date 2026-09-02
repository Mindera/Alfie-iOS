import ApolloAPI

extension GraphQLOperation {
    /// Queries are the only operations we issue that are safe to repeat and safe to store.
    ///
    /// Retry policy and cache policy both hang off this single fact, but each reads it through
    /// its own local name, so one can diverge from the other — an idempotent mutation could
    /// become retryable without also becoming cacheable.
    static var isQuery: Bool {
        operationType == .query
    }
}
