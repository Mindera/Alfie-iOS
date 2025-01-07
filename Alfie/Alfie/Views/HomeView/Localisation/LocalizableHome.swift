import Foundation

struct LocalizableHome: LocalizableProtocol {
    @LocalizableResource<Self>(.title) static var title
    @LocalizableResource<Self>(.searchBarPlaceholder) static var searchBarPlaceholder
    @LocalizableResource<Self>(.signIn) static var signIn
    @LocalizableResource<Self>(.signOut) static var signOut

    static func loggedInHeaderTitle(username: String, locale: Locale = .current) -> LocalizedStringResource {
        .init("KeyLoggedInHeaderTitle", defaultValue: "\(username)", table: tableName, locale: locale)
    }

    static func loggedInHeaderSubtitle(registrationYear: String, locale: Locale = .current) -> LocalizedStringResource {
        .init("KeyLoggedInHeaderSubtitle", defaultValue: "\(registrationYear)", table: tableName, locale: locale)
    }

    enum Keys: String, LocalizableKeyProtocol {
        case title = "KeyHome"
        case searchBarPlaceholder = "KeyHomeSearchBarPlaceholder"
        case signIn = "KeySignIn"
        case signOut = "KeySignOut"
    }
}
