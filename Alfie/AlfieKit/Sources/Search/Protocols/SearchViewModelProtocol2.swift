import Foundation
import Model

public protocol SearchViewModelProtocol2: ObservableObject {
    associatedtype RecentSearchesViewModel: RecentSearchesViewModelProtocol2

    var isSearchSubmissionAllowed: Bool { get }
    var searchText: String { get set }
    var state: SearchViewState { get }
    var suggestionTerms: [SearchSuggestionKeyword] { get }
    var suggestionBrands: [SearchSuggestionBrand] { get }
    var suggestionProducts: [Product] { get }
    var recentSearchesViewModel: RecentSearchesViewModel { get }

    func onSubmitSearch()
    func onTapSearchBrand(_ brand: SearchSuggestionBrand)
    func onTapSearchSuggestion(_ suggestion: SearchSuggestionKeyword)
    func onTapProduct(_ product: Product)
    func onTapOpenBrands()
    func viewDidAppear()
    func viewDidDisappear()
    func closeSearch()
}
