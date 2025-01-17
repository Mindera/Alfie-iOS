import Foundation

public protocol SearchServiceProtocol {
    func getSuggestion(term: String) async throws -> SearchSuggestion
}
