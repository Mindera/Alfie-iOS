import Model

public final class MockThemeService: ThemeServiceProtocol {
    public var selectedThemeID: String?
    public var onUpdateThemeAndReboot: ((String) -> Void)?
    public private(set) var updateThemeAndRebootCallCount = 0

    public init(selectedThemeID: String? = nil) {
        self.selectedThemeID = selectedThemeID
    }

    public func updateThemeAndReboot(_ themeID: String) {
        selectedThemeID = themeID
        updateThemeAndRebootCallCount += 1
        onUpdateThemeAndReboot?(themeID)
    }
}
