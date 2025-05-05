import Foundation

public protocol DebugConfigurationProviderProtocol: ConfigurationProviderProtocol {
    func toggleAvailability()
    func updateFeature(_ key: ConfigurationKey, isEnabled: Bool)
}
