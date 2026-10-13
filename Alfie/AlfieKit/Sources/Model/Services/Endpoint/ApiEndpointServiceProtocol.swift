import Foundation

public enum ApiEndpointOption: CaseIterable, Hashable, RawRepresentable {
    case dev
    case preProd
    case prod
    case custom(url: URL?)

    public var label: String {
        switch self {
        case .dev:
            "Development"
        case .preProd:
            "Pre-production"
        case .prod:
            "Production"
        case .custom:
            "Custom"
        }
    }

    public var customUrl: URL? {
        guard case .custom(let url) = self else {
            return nil
        }

        return url
    }

    public static var allCases: [ApiEndpointOption] {
        [.dev, .preProd, .prod, .custom(url: nil)]
    }

    public var rawValue: String {
        self.label
    }

    public init?(rawValue: String) {
        var optionToInit: ApiEndpointOption = .custom(url: nil)
        ApiEndpointOption.allCases.forEach { option in
            if option.label == rawValue {
                optionToInit = option
            }
        }
        self = optionToInit
    }
}

public protocol ApiEndpointServiceProtocol {
    var currentApiEndpoint: ApiEndpointOption { get }
    var lastCustomApiEndpoint: URL? { get }

    func updateApiEndpointAndReboot(_ option: ApiEndpointOption)
    func apiEndpoint(for option: ApiEndpointOption) -> URL
}
