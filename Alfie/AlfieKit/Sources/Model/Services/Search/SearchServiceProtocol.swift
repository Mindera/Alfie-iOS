import Foundation

public protocol SearchServiceProtocol {
    var suggestionsDebounceInterval: DispatchQueue.SchedulerTimeType.Stride { get }

    func getSuggestion(term: String) async throws -> SearchSuggestion
}
