import Foundation

public protocol SearchViewModelProtocol: ObservableObject {
    var isSearchSubmissionAllowed: Bool { get }
    var searchText: String { get set }
    var state: SearchViewState { get }
    var suggestionTerms: [SearchSuggestionKeyword] { get }
    var suggestionBrands: [SearchSuggestionBrand] { get }
    var suggestionProducts: [Product] { get }

    func onSubmitSearch()
    func onTapSearchSuggestion(_ suggestion: SearchSuggestionKeyword)
    func viewDidAppear()
    func viewDidDisappear()
}
