import Foundation

/// `UserDefaults`-backed theme-selection store. Persists the selected id and triggers a soft-reboot
/// on change, mirroring `ApiEndpointService`. The palette itself is applied in `AppDelegate.bootstrap`
/// (which re-runs on reboot and re-reads `selectedThemeID`), keeping Model free of any SharedUI type.
public final class ThemeService: ThemeServiceProtocol {
    private let userDefaults: UserDefaultsProtocol
    private let storageKey = "SELECTED_THEME_ID"
    private weak var appDelegate: AppDelegateProtocol?

    public private(set) var selectedThemeID: String?

    public init(appDelegate: AppDelegateProtocol, userDefaults: UserDefaultsProtocol) {
        self.appDelegate = appDelegate
        self.userDefaults = userDefaults
        self.selectedThemeID = userDefaults.value(for: storageKey)
    }

    public func updateThemeAndReboot(_ themeID: String) {
        userDefaults.set(themeID, for: storageKey)
        selectedThemeID = themeID
        appDelegate?.rebootApp()
    }
}
