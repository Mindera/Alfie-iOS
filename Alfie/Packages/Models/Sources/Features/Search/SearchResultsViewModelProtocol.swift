import Foundation

public enum SearchResultsViewModelState: Equatable {
    case empty
    case error
    case loading
    case recentSearches
    case success(results: [String])

    // swiftlint:disable vertical_whitespace_between_cases
    public var isEmpty: Bool {
        switch self {
        case .empty:
            return true
        default:
            return false
        }
    }

    public var didFail: Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }

    public var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
    // swiftlint:enable vertical_whitespace_between_cases

    public var results: [String]? {
        guard case .success(let results) = self else {
            return nil
        }
        return results
    }
}

public protocol SearchResultsViewModelProtocol: ObservableObject {
    var state: SearchResultsViewModelState { get }
    var searchText: String { get set }
}
