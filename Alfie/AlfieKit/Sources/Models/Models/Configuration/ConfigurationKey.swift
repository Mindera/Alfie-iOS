import Foundation

public enum ConfigurationKey: RawRepresentable, Hashable, CaseIterable {
    private enum Keys: String, CaseIterable {
        case appUpdate = "ios_app_update"
        case storeServices = "ios_store_services"
        case wishlist = "ios_wishlist"
    }

    public static var allCases: [ConfigurationKey] = Keys.allCases.compactMap {
        ConfigurationKey(rawValue: $0.rawValue)
    }

    // MARK: - Keys for settings
    case appUpdate

    // MARK: - Keys for features
    case storeServices
    // Define the wishlist as a "sample" key, enabled by default, so that unit tests have something to test properly
    case wishlist
    // More to be added as necessary...

    // MARK: - Custom key
    case custom(String) // Custom case for dynamic feature keys or unit tests

    public init?(rawValue: String) {
        guard let key = Keys(rawValue: rawValue) else {
            self = .custom(rawValue)
            return
        }

        // swiftlint:disable vertical_whitespace_between_cases
        switch key {
        case .appUpdate:
            self = .appUpdate
        case .storeServices:
            self = .storeServices
        case .wishlist:
            self = .wishlist
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    // Default availablity value for each key (for when there is no provider with a valid value available)
    // swiftlint:disable vertical_whitespace_between_cases
    public var defaultAvailabilityValue: Bool {
        switch self {
        case .appUpdate:
            return false
        case .storeServices:
            return false
        case .wishlist:
            return true
        default:
            // For now since we don't have any other actual configurable features yet, all default to "not available"
            // in the future we may want some to default to "available", so we must update this method accordingly
            return false
        }
    }

    public var rawValue: String {
        switch self {
        case .appUpdate:
            return Keys.appUpdate.rawValue
        case .storeServices:
            return Keys.storeServices.rawValue
        case .wishlist:
            return Keys.wishlist.rawValue
        case .custom(let key):
            return key
        }
    }
    // swiftlint:enable vertical_whitespace_between_cases
}
