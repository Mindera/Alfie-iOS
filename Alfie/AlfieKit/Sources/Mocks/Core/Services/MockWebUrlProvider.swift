import Foundation
import Model

public final class MockWebUrlProvider: WebURLProviderProtocol {
    public var scheme: String = ""
    public var host: String = ""

    public init() { }

    public init(scheme: String,
                host: String) {
        self.scheme = scheme
        self.host = host
    }

    public var onUrlCalled: ((_ endpoint: WebURLEndpoint) -> URL?)?
    public func url<E: WebURLEndpoint>(for endpoint: E) -> URL? {
        onUrlCalled?(endpoint)
    }
}
