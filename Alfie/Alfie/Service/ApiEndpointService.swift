import Common
import Core
import Models
import Foundation

final class ApiEndpointService: NSObject, ApiEndpointServiceProtocol {
    private let apiUrlUserDefaultsKey: String
    private let userDefaults: UserDefaultsProtocol
    private let rebootDelay: TimeInterval
    private weak var appDelegate: AppDelegateProtocol?

    private(set) var currentApiEndpoint: ApiEndpointOption

    init(appDelegate: AppDelegateProtocol,
         userDefaults: UserDefaultsProtocol,
         userDefaultsKey: String = "com.alfie.config.api.endpoint",
         rebootDelay: TimeInterval = 5) {
        self.appDelegate = appDelegate
        self.userDefaults = userDefaults
        self.apiUrlUserDefaultsKey = userDefaultsKey
        self.rebootDelay = rebootDelay
        let storedApiUrl: String? = userDefaults.value(for: userDefaultsKey)
        self.currentApiEndpoint = ApiEndpointOption.option(with: storedApiUrl)
    }

    func updateApiEndpointAndReboot(_ option: ApiEndpointOption) {
        log("API endpoint changed to \(option.url.absoluteString), will reboot app")
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
    case dev = "https://mock-server-rose.vercel.app/"
    case preProd = "https://api-preprod.mock-server-rose.vercel.app/"
    case prod = "https://api.mock-server-rose.vercel.app/"
    case custom = "https://api-preview-000.mock-server-rose.vercel.app/"

    static func url(for option: ApiEndpointOption) -> String {
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
    }
}

private extension ApiEndpointOption {
    var url: URL {
        let url: URL? = switch self {
                            case let .custom(customUrl):
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
            logError(message)
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

        return ApiEndpointOption.allCases.first(where: { $0.url.absoluteString == url && $0 != .custom(url: nil) }) ?? .custom(url: URL(string: url))
    }

    static var defaultOption: ApiEndpointOption {
        ReleaseConfigurator.isRelease ? .prod : .dev
    }
}
