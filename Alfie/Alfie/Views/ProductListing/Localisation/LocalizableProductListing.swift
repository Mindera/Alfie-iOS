import Foundation

struct LocalizableProductListing: LocalizableProtocol {
    @LocalizableResource<Self>(.errorTitle) static var errorTitle
    @LocalizableResource<Self>(.errorMessage) static var errorMessage
    @LocalizableResource<Self>(.filters) static var filters

    static func results(_ number: Int, locale: Locale = .current) -> LocalizedStringResource {
        .init("KeyResults", defaultValue: "\(number)", table: tableName, locale: locale)
    }

    enum Keys: String, LocalizableKeyProtocol {
        case errorTitle = "KeyErrorTitle"
        case errorMessage = "KeyErrorMessage"
        case filters = "KeyFilters"
    }
}
