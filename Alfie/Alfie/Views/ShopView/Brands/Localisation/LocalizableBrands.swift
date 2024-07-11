import Foundation

struct LocalizableBrands: LocalizableProtocol {
    @LocalizableResource<Self>(.errorTitle) static var errorTitle
    @LocalizableResource<Self>(.errorMessage) static var errorMessage
    @LocalizableResource<Self>(.searchBarPlaceholder) static var searchBarPlaceholder
    @LocalizableResource<Self>(.searchNoResultsMessage) static var searchNoResultsMessage

    enum Keys: String, LocalizableKeyProtocol {
        case errorTitle = "KeyErrorTitle"
        case errorMessage = "KeyErrorMessage"
        case searchBarPlaceholder = "KeySearchBarPlaceholder"
        case searchNoResultsMessage = "KeySearchNoResultsMessage"
    }
}
