import Foundation

public protocol WebURLProviderProtocol {
    var scheme: String { get }
    var host: String { get }

    func url<E: WebURLEndpoint>(for endpoint: E) -> URL?
}
