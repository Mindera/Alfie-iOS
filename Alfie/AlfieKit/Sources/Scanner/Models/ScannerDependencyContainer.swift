import AlicerceLogging
import Foundation
import Model

public final class ScannerDependencyContainer {
    let deepLinkService: DeepLinkServiceProtocol
    let productService: ProductServiceProtocol
    /// A factory rather than an instance: each presentation of the scanner gets its own camera
    /// session, and the previous one is released with the screen that owned it. Supplied by the app
    /// graph, which is the only layer that knows the real implementation.
    let makeScanService: () -> CameraScanServiceProtocol
    let analytics: AlfieAnalyticsTracker
    let haptics: HapticsServiceProtocol
    let schedule: (_ delay: TimeInterval, _ work: @escaping () -> Void) -> Void
    let log: Logger

    public init(
        deepLinkService: DeepLinkServiceProtocol,
        productService: ProductServiceProtocol,
        makeScanService: @escaping () -> CameraScanServiceProtocol,
        analytics: AlfieAnalyticsTracker,
        haptics: HapticsServiceProtocol,
        schedule: @escaping (_ delay: TimeInterval, _ work: @escaping () -> Void) -> Void = { delay, work in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        },
        log: Logger
    ) {
        self.deepLinkService = deepLinkService
        self.productService = productService
        self.makeScanService = makeScanService
        self.analytics = analytics
        self.haptics = haptics
        self.schedule = schedule
        self.log = log
    }
}
