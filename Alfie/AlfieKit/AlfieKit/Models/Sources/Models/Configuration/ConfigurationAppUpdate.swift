import Foundation

// MARK: - Local Configuration

public struct AppUpdateInfo {
    public let minimumAppVersion: Version
    public let title: String
    public let message: String
    public let backgroundImage: URL?
    public let confirmActionText: String
    public let cancelActionText: String?
    public let url: URL?

    public init(
        minimumAppVersion: Version,
        title: String,
        message: String,
        backgroundImage: URL?,
        confirmActionText: String,
        cancelActionText: String?,
        url: URL?
    ) {
        self.minimumAppVersion = minimumAppVersion
        self.title = title
        self.message = message
        self.backgroundImage = backgroundImage
        self.confirmActionText = confirmActionText
        self.cancelActionText = cancelActionText
        self.url = url
    }

    public init(configuration: ConfigurationAppUpdateInfo, url: URL?) {
        self.minimumAppVersion = configuration.minimumAppVersion
        self.title = configuration.title
        self.message = configuration.message
        self.backgroundImage = configuration.backgroundImage
        self.confirmActionText = configuration.confirmActionText
        self.cancelActionText = configuration.cancelActionText
        self.url = url
    }
}

// MARK: - Remote Configuration Models

public struct ConfigurationAppUpdate: Codable {
    public let url: String
    public let requirements: ConfigurationAppUpdateRequirements

    public init(url: String, requirements: ConfigurationAppUpdateRequirements) {
        self.url = url
        self.requirements = requirements
    }
}

public struct ConfigurationAppUpdateRequirements: Codable {
    public let immediate: ConfigurationAppUpdateInfo?
    public let flexible: ConfigurationAppUpdateInfo?

    public init(immediate: ConfigurationAppUpdateInfo?, flexible: ConfigurationAppUpdateInfo?) {
        self.immediate = immediate
        self.flexible = flexible
    }
}

public struct ConfigurationAppUpdateInfo: Codable {
    public let minimumAppVersion: Version
    public let title: String
    public let message: String
    public let backgroundImage: URL?
    public let confirmActionText: String
    public let cancelActionText: String?

    enum CodingKeys: String, CodingKey {
        case minimumAppVersion = "if_under_version"
        case title
        case message
        case backgroundImage = "background_image"
        case confirmActionText = "confirm_action_text"
        case cancelActionText = "cancel_action_text"
    }

    public init(
        minimumAppVersion: Version,
        title: String,
        message: String,
        backgroundImage: URL?,
        confirmActionText: String,
        cancelActionText: String?
    ) {
        self.minimumAppVersion = minimumAppVersion
        self.title = title
        self.message = message
        self.backgroundImage = backgroundImage
        self.confirmActionText = confirmActionText
        self.cancelActionText = cancelActionText
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let versionString = try container.decode(String.self, forKey: .minimumAppVersion)
        self.minimumAppVersion = Version(versionString)
        self.title = try container.decode(String.self, forKey: .title)
        self.message = try container.decode(String.self, forKey: .message)
        let backgroundImageURL = try container.decodeIfPresent(String.self, forKey: .backgroundImage)
        self.backgroundImage = {
            guard let backgroundImageURL, !backgroundImageURL.isEmpty else {
                return nil
            }
            return URL(string: backgroundImageURL)
        }()
        self.confirmActionText = try container.decode(String.self, forKey: .confirmActionText)
        self.cancelActionText = try container.decodeIfPresent(String.self, forKey: .cancelActionText)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(minimumAppVersion.stringValue, forKey: .minimumAppVersion)
        try container.encode(title, forKey: .title)
        try container.encode(message, forKey: .message)
        try container.encode(backgroundImage, forKey: .backgroundImage)
        try container.encode(confirmActionText, forKey: .confirmActionText)
        try container.encode(cancelActionText, forKey: .cancelActionText)
    }
}
