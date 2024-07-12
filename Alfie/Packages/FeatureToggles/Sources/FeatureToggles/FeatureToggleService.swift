import Foundation
import SQLite3

/// `FeatureToggleService` is a singleton class responsible for managing feature toggles in the application.
/// It provides methods to load, update, and check the status of feature toggles.
/// The feature toggles are stored in `UserDefaults` to ensure persistence across app restarts.
public class FeatureToggleService: ObservableObject {
    public static let shared = FeatureToggleService()
    private let userDefaultsKey = "featureToggles"
    @Published public var toggles: [String: FeatureToggle] = [:]

    private init() {
        loadTogglesFromUserDefaults()
    }
    /// Loads the feature toggles from `UserDefaults` into the `toggles` dictionary.
    private func loadTogglesFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedToggles = try? JSONDecoder().decode([String: FeatureToggle].self, from: data) {
            self.toggles = savedToggles
        }
    }
    /// Saves the current feature toggles from the `toggles` dictionary to `UserDefaults`.
    private func saveTogglesToUserDefaults() {
        if let data = try? JSONEncoder().encode(toggles) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    /// Updates the state of a feature toggle and persists the change to `UserDefaults`.
        /// - Parameters:
        ///   - featureName: The name of the feature toggle.
        ///   - isEnabled: An optional boolean value indicating whether the feature is enabled.
        ///   - stringValue: An optional string value associated with the feature toggle.
        public func updateFeatureToggle(_ featureName: String, isEnabled: Bool? = nil, stringValue: String? = nil) {
            var toggle = toggles[featureName] ?? FeatureToggle(featureName: featureName, isEnabled: isEnabled)
            if let isEnabled = isEnabled {
                toggle = FeatureToggle(
                    featureName: toggle.featureName,
                    isEnabled: isEnabled,
                    stringValue: toggle.stringValue
                )
            }
            if let stringValue = stringValue {
                toggle = FeatureToggle(featureName: toggle.featureName, stringValue: stringValue)
            }
            toggles[featureName] = toggle
            saveTogglesToUserDefaults()  // Save after updating the toggle
        }
    /// Checks if a feature is enabled.
    /// - Parameter featureName: The name of the feature toggle.
    /// - Returns: A boolean value indicating whether the feature is enabled.
    public func isFeatureEnabled(_ featureName: String) -> Bool {
        toggles[featureName]?.isEnabled ?? false
    }
}
