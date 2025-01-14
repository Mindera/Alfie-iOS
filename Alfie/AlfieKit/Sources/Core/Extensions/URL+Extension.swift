import Foundation
import Models

extension URL {
    public func httpSecureUrl(using configuration: LinkConfigurationProtocol) -> URL {
        guard
            self.scheme != configuration.defaultHttpScheme,
            var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        else {
            return self
        }
        components.scheme = configuration.defaultHttpScheme
        return components.url ?? self
    }
}
