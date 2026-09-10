import AlicerceLogging
import Model

public final class ScannerDependencyContainer {
    let deepLinkService: DeepLinkServiceProtocol
    /// A factory rather than an instance: each presentation of the scanner gets its own camera
    /// session, and the previous one is released with the screen that owned it. Supplied by the app
    /// graph, which is the only layer that knows the real implementation.
    let makeScanService: () -> CameraScanServiceProtocol
    let log: Logger

    public init(
        deepLinkService: DeepLinkServiceProtocol,
        makeScanService: @escaping () -> CameraScanServiceProtocol,
        log: Logger
    ) {
        self.deepLinkService = deepLinkService
        self.makeScanService = makeScanService
        self.log = log
    }
}
