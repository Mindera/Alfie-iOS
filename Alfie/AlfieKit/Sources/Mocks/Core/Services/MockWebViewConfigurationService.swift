import Foundation
import Models

public final class MockWebViewConfigurationService: WebViewConfigurationServiceProtocol {
    public init() { }

    public var onUrlForFeatureCalled: ((WebFeature) -> URL?)?
    public func url(for feature: WebFeature) async -> URL? {
        onUrlForFeatureCalled?(feature)
    }
}
