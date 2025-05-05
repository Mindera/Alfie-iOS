import AlicerceLogging
import Foundation
import Model

public final class WebViewConfigurationService: WebViewConfigurationServiceProtocol {
    private let bffClient: BFFClientServiceProtocol
    private var configuration: WebViewConfiguration?
    private let log: Logger

    public init(bffClient: BFFClientServiceProtocol, log: Logger) {
        self.bffClient = bffClient
        self.log = log

        Task {
            await fetchConfiguration()
        }
    }

    // MARK: - WebViewConfigurationServiceProtocol

    public func url(for feature: WebFeature) async -> URL? {
        if configuration == nil {
            await fetchConfiguration()
        }

        return configuration?.url(for: feature)
    }

    // MARK: - Private

    private func fetchConfiguration() async {
        do {
            configuration = try await bffClient.getWebViewConfig()
        } catch {
            log.error("Error fetching webview configuration: \(error)")
        }
    }
}
