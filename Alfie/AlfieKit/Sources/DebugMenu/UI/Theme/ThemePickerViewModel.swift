import Model
import SharedUI

public final class ThemePickerViewModel {
    private let themeService: ThemeServiceProtocol

    public let themes: [AppTheme] = AppTheme.allCases

    public init(themeService: ThemeServiceProtocol) {
        self.themeService = themeService
    }

    /// The active theme id — the persisted selection, or the default when none was chosen yet.
    public var selectedThemeID: String {
        themeService.selectedThemeID ?? AppTheme.alfie.rawValue
    }

    public func isSelected(_ theme: AppTheme) -> Bool {
        theme.rawValue == selectedThemeID
    }

    /// Debug-only display names (hardcoded like the other Debug-menu strings — no L10n).
    public func displayName(for theme: AppTheme) -> String {
        switch theme {
        case .alfie:
            return "Alfie"
        case .selffridge:
            return "Selfridges"
        }
    }

    public func select(_ theme: AppTheme) {
        guard theme.rawValue != selectedThemeID else { return }
        themeService.updateThemeAndReboot(theme.rawValue)
    }
}
