import Foundation

/// `UserDefaults`-backed theme-selection store, mirroring the app's other simple preference
/// providers (e.g. `ProductListingStyleProvider`).
public final class ThemeService: ThemeServiceProtocol {
    private let userDefaults: UserDefaultsProtocol
    private let storageKey = "SELECTED_THEME_ID"

    public private(set) var selectedThemeID: String?

    public init(userDefaults: UserDefaultsProtocol) {
        self.userDefaults = userDefaults
        self.selectedThemeID = userDefaults.value(for: storageKey)
    }

    public func set(_ themeID: String) {
        userDefaults.set(themeID, for: storageKey)
        selectedThemeID = themeID
    }
}
