import AlicerceLogging
import Foundation
import Model

public final class ScannerDependencyContainer {
    let deepLinkService: DeepLinkServiceProtocol
    /// A factory rather than an instance: each presentation of the scanner gets its own camera
    /// session, and the previous one is released with the screen that owned it. Supplied by the app
    /// graph, which is the only layer that knows the real implementation.
    let makeScanService: () -> CameraScanServiceProtocol
    let analytics: AlfieAnalyticsTracker
    let haptics: HapticsServiceProtocol
    let isCameraAccessUndetermined: () -> Bool
    /// Runs the hand-off once the recognised state has been on screen long enough to be seen.
    let afterRecognitionFeedback: (@escaping () -> Void) -> Void
    let log: Logger

    public init(
        deepLinkService: DeepLinkServiceProtocol,
        makeScanService: @escaping () -> CameraScanServiceProtocol,
        analytics: AlfieAnalyticsTracker,
        haptics: HapticsServiceProtocol,
        isCameraAccessUndetermined: @escaping () -> Bool,
        afterRecognitionFeedback: @escaping (@escaping () -> Void) -> Void = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: $0)
        },
        log: Logger
    ) {
        self.deepLinkService = deepLinkService
        self.makeScanService = makeScanService
        self.analytics = analytics
        self.haptics = haptics
        self.isCameraAccessUndetermined = isCameraAccessUndetermined
        self.afterRecognitionFeedback = afterRecognitionFeedback
        self.log = log
    }
}
