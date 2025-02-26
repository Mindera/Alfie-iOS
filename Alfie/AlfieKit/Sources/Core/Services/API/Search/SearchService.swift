import Foundation
import Models

public final class SearchService: SearchServiceProtocol {
    private let bffClient: BFFClientServiceProtocol
    public let suggestionsDebounceInterval: DispatchQueue.SchedulerTimeType.Stride

    // MARK: - Public

    public init(bffClient: BFFClientServiceProtocol) {
        self.bffClient = bffClient
        self.suggestionsDebounceInterval = .seconds(0.5)
    }

    public func getSuggestion(term: String) async throws -> SearchSuggestion {
        try await bffClient.getSearchSuggestion(term: term)
    }
}
