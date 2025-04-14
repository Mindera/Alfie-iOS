import Foundation
import Model

public final class SearchService: SearchServiceProtocol {
    private let bffClient: BFFClientServiceProtocol
    public let suggestionsDebounceInterval: DispatchQueue.SchedulerTimeType.Stride

    // MARK: - Public

    public init(
        bffClient: BFFClientServiceProtocol,
        suggestionsDebounceInterval: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.5)
    ) {
        self.bffClient = bffClient
        self.suggestionsDebounceInterval = suggestionsDebounceInterval
    }

    public func getSuggestion(term: String) async throws -> SearchSuggestion {
        try await bffClient.getSearchSuggestion(term: term)
    }
}
