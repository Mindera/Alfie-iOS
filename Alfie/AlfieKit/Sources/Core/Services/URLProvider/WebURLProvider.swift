import AlicerceLogging
import Foundation
import Models

public final class WebURLProvider: WebURLProviderProtocol {
    public var host: String
    public var scheme: String
    private let log: Logger
    
    public init(
        scheme: String = "https",
        host: String,
        log: Logger
    ) {
        self.scheme = scheme
        self.host = host
        self.log = log
    }

    public func url<E: WebURLEndpoint>(for endpoint: E) -> URL? {
        guard isAbsoluteWebUrl else {
            log.error("URL scheme is invalid for web: \(scheme)")
            return nil
        }

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = endpoint.path.prefixIfNeeded(with: "/")
        if let parameters = endpoint.parameters, !parameters.isEmpty {
            components.queryItems = parameters.sorted(by: \.key).map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }

        guard let url = components.url else {
            log.error("Error building URL for path: \(endpoint.path)")
            return nil
        }
        return url
    }

    private var isAbsoluteWebUrl: Bool {
        scheme == "https" || scheme == "http"
    }
}

private extension Sequence {
    func sorted<C: Comparable>(by keyPath: KeyPath<Element, C>) -> [Element] {
        sorted { left, rigth -> Bool in
            left[keyPath: keyPath] < rigth[keyPath: keyPath]
        }
    }
}
