import Foundation

struct LocalizableProductListing: LocalizableProtocol {
    @LocalizableResource<Self>(.errorTitle) static var errorTitle
    @LocalizableResource<Self>(.errorMessage) static var errorMessage
    @LocalizableResource<Self>(.listStyleTitle) static var listStyleTitle
    @LocalizableResource<Self>(.refineButtonTitle) static var refineButtonTitle
    @LocalizableResource<Self>(.refineAndSortTitle) static var refineAndSortTitle
    @LocalizableResource<Self>(.showResults) static var showResults
    @LocalizableResource<Self>(.sortByTitle) static var sortByTitle

    static func results(_ number: Int, locale: Locale = .current) -> LocalizedStringResource {
        .init("KeyResults", defaultValue: "\(number)", table: tableName, locale: locale)
    }

    enum Keys: String, LocalizableKeyProtocol {
        case errorTitle = "KeyErrorTitle"
        case errorMessage = "KeyErrorMessage"
        case listStyleTitle = "KeyListStyleTitle"
        case refineButtonTitle = "KeyRefineButtonTitle"
        case refineAndSortTitle = "KeyRefineAndSortTitle"
        case showResults = "KeyShowResults"
        case sortByTitle = "KeySortByTitle"
    }
}
