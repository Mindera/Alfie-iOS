import Foundation

public struct ConfigurationUserConfig: Codable {
    public let available: Bool
    public let countryCodes: [String]
    public let releaseTypes: [String]

    enum CodingKeys: String, CodingKey {
        case available
        case countryCodes = "available_country_codes"
        case releaseTypes = "available_release_types"
    }

    public init(available: Bool, countryCodes: [String], releaseTypes: [String]) {
        self.available = available
        self.countryCodes = countryCodes
        self.releaseTypes = releaseTypes
    }
}

public struct ConfigurationVersion: Codable {
    public let minimumAppVersion: Version
    public let registeredUsersConfig: ConfigurationUserConfig
    public let guestUsersConfig: ConfigurationUserConfig

    enum CodingKeys: String, CodingKey {
        case minimumAppVersion = "minimum_app_version"
        case registeredUsersConfig = "registered_users"
        case guestUsersConfig = "guest_users"
    }

    public init(minimumAppVersion: Version,
                registeredUsersConfig: ConfigurationUserConfig,
                guestUsersConfig: ConfigurationUserConfig) {
        self.minimumAppVersion = minimumAppVersion
        self.registeredUsersConfig = registeredUsersConfig
        self.guestUsersConfig = guestUsersConfig
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let versionString = try container.decode(String.self, forKey: .minimumAppVersion)
        self.minimumAppVersion = Version(versionString)
        self.registeredUsersConfig = try container.decode(ConfigurationUserConfig.self, forKey: .registeredUsersConfig)
        self.guestUsersConfig = try container.decode(ConfigurationUserConfig.self, forKey: .guestUsersConfig)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(minimumAppVersion.stringValue, forKey: .minimumAppVersion)
        try container.encode(registeredUsersConfig, forKey: .registeredUsersConfig)
        try container.encode(guestUsersConfig, forKey: .guestUsersConfig)
    }
}

public struct ConfigurationVersions: Codable {
    public let versions: [ConfigurationVersion]
}

public struct ConfigurationValue {
    public private(set) var boolValue: Bool?
    public private(set) var versionsValue: ConfigurationVersions?
    public private(set) var appUpdate: ConfigurationAppUpdate?

    public init?(rawValue: Any) {
        if let dataValue = rawValue as? Data, let value = try? JSONDecoder().decode(ConfigurationVersions.self, from: dataValue) {
            self.versionsValue = value
        } else if let dataValue = rawValue as? Data, let value = try? JSONDecoder().decode(ConfigurationAppUpdate.self, from: dataValue) {
            self.appUpdate = value
        } else if let boolValue = rawValue as? Bool {
            self.boolValue = boolValue
        } else if let dataValue = rawValue as? Data, let boolValue = String(data: dataValue, encoding: .utf8).flatMap(Bool.init) {
            self.boolValue = boolValue
        } else {
            assertionFailure("Tried to create ConfigurationValue with unexpected value type: \(rawValue)")
            return nil
        }
    }
}
