import Core
import Foundation
import Model

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
    /// Toggle the `dev` environment to point at the legacy Alfie-Mocks server
    /// (`localhost:4000`) instead of the BFF (`localhost:3000`). Useful during the
    /// schema-divergence transition while iOS queries are migrated to the BFF.
    /// Flip in code and rebuild.
    static var useLegacyMockDev: Bool = false

    /// Legacy Alfie-Mocks server URL — used as the `dev` URL when `useLegacyMockDev` is `true`.
    static let legacyMockDevUrl = "http://localhost:4000/"

    // Local dev: aligned with the BFF default port. BFFClientService appends `graphql` /
    // `config/webviews` to this base, so it must stay an origin root (trailing slash, no path).
    case dev = "http://localhost:3000/"
    // TODO: Real PreProd/Prod BFF environment URLs are not provisioned yet — these are
    // explicit TBD placeholders. Replace once the real environments exist.
    case preProd = "https://preprod.bff.tbd.invalid/"
    case prod = "https://prod.bff.tbd.invalid/"

    static func url(for option: ApiEndpointOption) -> String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch option {
        case .dev:
            useLegacyMockDev ? legacyMockDevUrl : ApiEndpointUrl.dev.rawValue
        case .preProd:
            ApiEndpointUrl.preProd.rawValue
        case .prod:
            ApiEndpointUrl.prod.rawValue
        case .custom:
            ApiEndpointUrl.dev.rawValue
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
                URL(string: ApiEndpointUrl.dev.rawValue)
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
