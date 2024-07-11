import Foundation

struct LocalizableCategories: LocalizableProtocol {
    @LocalizableResource<Self>(.errorTitle) static var errorTitle
    @LocalizableResource<Self>(.errorMessage) static var errorMessage

    enum Keys: String, LocalizableKeyProtocol {
        case errorTitle = "KeyCategoriesErrorTitle"
        case errorMessage = "KeyCategoriesErrorMessage"
    }
}
