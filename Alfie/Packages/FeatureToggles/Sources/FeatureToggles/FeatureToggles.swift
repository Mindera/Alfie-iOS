import Foundation

public struct FeatureToggle: Codable {
    public let featureName: String
    public let isEnabled: Bool?
    public let stringValue: String?
    
    public init(featureName: String, isEnabled: Bool? = nil, stringValue: String? = nil) {
        self.featureName = featureName
        self.isEnabled = isEnabled
        self.stringValue = stringValue
    }
}
