import Core
import Foundation
import Models

final class ApiEndpointService: NSObject, ApiEndpointServiceProtocol {
    private let apiUrlUserDefaultsKey: String
    private let userDefaults: UserDefaultsProtocol
    private let rebootDelay: TimeInterval
    private weak var appDelegate: AppDelegateProtocol?

    private(set) var currentApiEndpoint: ApiEndpointOption

    init(
        appDelegate: AppDelegateProtocol,
        userDefaults: UserDefaultsProtocol,
        userDefaultsKey: String = "com.alfie.config.api.endpoint",
        rebootDelay: TimeInterval = 5
    ) {
        self.appDelegate = appDelegate
        self.userDefaults = userDefaults
        self.apiUrlUserDefaultsKey = userDefaultsKey
        self.rebootDelay = rebootDelay
        let storedApiUrl: String? = userDefaults.value(for: userDefaultsKey)
        self.currentApiEndpoint = ApiEndpointOption.option(with: storedApiUrl)
    }

    func updateApiEndpointAndReboot(_ option: ApiEndpointOption) {
        log.debug("API endpoint changed to \(option.url.absoluteString), will reboot app")
        userDefaults.set(option.url.absoluteString, for: apiUrlUserDefaultsKey)
        // Make sure user defaults are synced before rebooting the app
        DispatchQueue.main.asyncAfter(deadline: .now() + rebootDelay) { [weak self] in
            self?.appDelegate?.rebootApp()
        }
    }

    func apiEndpoint(for option: ApiEndpointOption) -> URL {
        option.url
    }
}

enum ApiEndpointUrl: String {
    case dev = "http://localhost:4000/"
    case preProd = "https://api-preprod.localhost:4000/"
    case prod = "https://api.localhost:4000/"
    case custom = "https://api-preview-000.localhost:4000/"

    static func url(for option: ApiEndpointOption) -> String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch option {
        case .dev:
            ApiEndpointUrl.dev.rawValue
        case .preProd:
            ApiEndpointUrl.preProd.rawValue
        case .prod:
            ApiEndpointUrl.prod.rawValue
        case .custom:
            ApiEndpointUrl.custom.rawValue
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

private extension ApiEndpointOption {
    var url: URL {
        let url: URL? = switch self {
        case .custom(let customUrl):
            if customUrl != nil {
                customUrl
            } else {
                URL(string: ApiEndpointUrl.custom.rawValue)
            }

        default:
            URL(string: ApiEndpointUrl.url(for: self))
        }

        guard let url else {
            let message = "Cannot build API endpoint URL for option \(self.label)"
            log.error(message)
            return URL(fileURLWithPath: "")
        }

        return url
    }

    static func option(with url: String?) -> ApiEndpointOption {
        guard
            let url,
            !url.isEmpty
        else {
            return Self.defaultOption
        }

        return ApiEndpointOption
            .allCases
            .first { $0.url.absoluteString == url && $0 != .custom(url: nil) } ?? .custom(url: URL(string: url))
    }

    static var defaultOption: ApiEndpointOption {
        ReleaseConfigurator.isRelease ? .prod : .dev
    }
}
