import Foundation

/// Persists the user's selected colour-theme id across launches and applies it via a soft-reboot,
/// mirroring `ApiEndpointServiceProtocol`'s update-and-reboot pattern. The id is an opaque `String`
/// (the design-token theme mode, e.g. `"alfie-theme"`); Model deliberately doesn't know the set of
/// themes — that lives in the generated `AppTheme` in SharedUI, and the app layer maps id → palette.
public protocol ThemeServiceProtocol {
    /// The persisted selection, or `nil` if the user has never chosen one (app layer applies its default).
    var selectedThemeID: String? { get }

    /// Persist `themeID` and soft-reboot so the whole UI re-renders in the new theme.
    func updateThemeAndReboot(_ themeID: String)
}
