import Foundation

/// Persists the user's selected colour-theme id across launches. The id is an opaque `String`
/// (the design-token theme mode, e.g. `"alfie-theme"`); Model deliberately doesn't know the set of
/// themes — that lives in the generated `AppTheme` in SharedUI, and the app layer maps id → palette.
public protocol ThemeServiceProtocol {
    /// The persisted selection, or `nil` if the user has never chosen one (app layer applies its default).
    var selectedThemeID: String? { get }
    func set(_ themeID: String)
}
