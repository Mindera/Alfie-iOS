import Foundation

struct LocalizableSearch: LocalizableProtocol {
    @LocalizableResource<Self>(.title) static var title
    @LocalizableResource<Self>(.searchBarPlaceholder) static var searchBarPlaceholder
    @LocalizableResource<Self>(.searchBarPlaceholderFocused) static var searchBarPlaceholderFocused
    @LocalizableResource<Self>(.cancel) static var cancel
    @LocalizableResource<Self>(.searchEmptyTitle) static var searchEmptyTitle
    @LocalizableResource<Self>(.searchEmptyMessage) static var searchEmptyMessage

    @LocalizableResource<Self>(.recentSearchesHeaderTitle) static var recentSearchesHeaderTitle
    @LocalizableResource<Self>(.recentSearchesClearAllTitle) static var recentSearchesClearAllTitle

    @LocalizableResource<Self>(.suggestionsMore) static var suggestionsMore
    @LocalizableResource<Self>(.suggestionsTitle) static var suggestionsTitle
    @LocalizableResource<Self>(.suggestionsBrands) static var suggestionsBrands
    @LocalizableResource<Self>(.suggestionsProducts) static var suggestionsProducts

    @LocalizableResource<Self>(.searchNoResultsHelp) static var searchNoResultsHelp
    @LocalizableResource<Self>(.searchNoResultsLink) static var searchNoResultsLink

    static func searchNoResults(for term: String, locale: Locale = .current) -> LocalizedStringResource {
        .init("KeySearchNoResultsMessageTerm", defaultValue: "\(term)", table: tableName, locale: locale)
    }

    enum Keys: String, LocalizableKeyProtocol {
        case title = "KeySearch"
        case searchBarPlaceholder = "KeySearchPlaceholder"
        case searchBarPlaceholderFocused = "KeySearchPlaceholderFocused"
        case cancel = "KeyCancel"
        case searchEmptyTitle = "KeySearchEmptyTitle"
        case searchEmptyMessage = "KeySearchEmptyMessage"
        case recentSearchesHeaderTitle = "KeyRecentSearchesHeaderTitle"
        case recentSearchesClearAllTitle = "KeyRecentSearchesClearAllTitle"

        case suggestionsMore = "KeySuggestionsMore"
        case suggestionsTitle = "KeySuggestionsTitle"
        case suggestionsBrands = "KeySuggestionsBrands"
        case suggestionsProducts = "KeySuggestionsProducts"

        case searchNoResultsHelp = "KeySearchNoResultsHelp"
        case searchNoResultsLink = "KeySearchNoResultsLink"
    }
}
