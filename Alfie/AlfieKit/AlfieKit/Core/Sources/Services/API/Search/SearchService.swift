import Foundation
import Models

public final class SearchService: SearchServiceProtocol {
    private let bffClient: BFFClientServiceProtocol

    // MARK: - Public

    public init(bffClient: BFFClientServiceProtocol) {
        self.bffClient = bffClient
    }

    public func getSuggestion(term: String) async throws -> SearchSuggestion {
        try await bffClient.getSearchSuggestion(term: term)
    }
}
