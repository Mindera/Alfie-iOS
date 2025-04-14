import Combine
import Foundation

public protocol WebViewConfigurationServiceProtocol {
    func url(for feature: WebFeature) async -> URL?
}
