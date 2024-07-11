import Foundation
import Models

// MARK: - Local

extension AppUpdateInfo {
    public static func fixture(minimumAppVersion: Version = .init("0.0.0"),
                               title: String = "Please Update",
                               message: String = "Please update to continue using the app. We have launched new and faster app.",
                               backgroundImage: URL? = nil,
                               confirmActionText: String = "Update",
                               cancelActionText: String? = nil,
                               url: URL? = nil) -> AppUpdateInfo {

        .init(
            minimumAppVersion: minimumAppVersion,
            title: title,
            message: message,
            backgroundImage: backgroundImage,
            confirmActionText: confirmActionText,
            cancelActionText: cancelActionText,
            url: url
        )
    }
}

// MARK: - Remote

extension ConfigurationAppUpdate {
    public static func fixture(url: String = "https://apps.apple.com/app/id{appID}",
                               requirements: ConfigurationAppUpdateRequirements) -> ConfigurationAppUpdate {
        .init(
            url: url,
            requirements: requirements
        )
    }
}

extension ConfigurationAppUpdateRequirements {
    public static func fixture(immediate: ConfigurationAppUpdateInfo? = nil,
                               flexible: ConfigurationAppUpdateInfo? = nil) -> ConfigurationAppUpdateRequirements {
        .init(immediate: immediate, flexible: flexible)
    }
}

extension ConfigurationAppUpdateInfo {
    public static func fixture(minimumAppVersion: Version = .init("0.0.0"),
                               title: String = "Please Update",
                               message: String = "Please update to continue using the app. We have launched new and faster app.",
                               backgroundImage: URL? = nil,
                               confirmActionText: String = "Update",
                               cancelActionText: String? = nil) -> ConfigurationAppUpdateInfo {

        .init(
            minimumAppVersion: minimumAppVersion,
            title: title,
            message: message,
            backgroundImage: backgroundImage,
            confirmActionText: confirmActionText,
            cancelActionText: cancelActionText
        )
    }
}
