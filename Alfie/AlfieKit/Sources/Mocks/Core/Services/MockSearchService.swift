import Foundation
import Models

public final class MockSearchService: SearchServiceProtocol {
    public init() { }

    public var suggestionsDebounceInterval: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.5)
    public var onGetSuggestionCalled: ((String) throws -> SearchSuggestion)?
    public func getSuggestion(term: String) async throws -> SearchSuggestion {
        guard let suggestion = try onGetSuggestionCalled?(term) else {
            throw BFFRequestError(type: .generic)
        }
        return suggestion
    }
}
