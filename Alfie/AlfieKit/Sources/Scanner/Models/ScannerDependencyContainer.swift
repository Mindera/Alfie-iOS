import AlicerceLogging
import Model

public final class ScannerDependencyContainer {
    let deepLinkService: DeepLinkServiceProtocol
    /// A factory rather than an instance: each presentation of the scanner gets its own camera
    /// session, and the previous one is released with the screen that owned it. Supplied by the app
    /// graph, which is the only layer that knows the real implementation.
    let makeScanService: () -> CameraScanServiceProtocol
    /// Sends the shopper to this app's page in the system Settings, the only place a refused camera
    /// can be granted. Supplied by the app graph rather than reached for here: it leaves the app,
    /// which is not something a feature module should know how to do.
    let openAppSettings: () -> Void
    let log: Logger

    public init(
        deepLinkService: DeepLinkServiceProtocol,
        makeScanService: @escaping () -> CameraScanServiceProtocol,
        openAppSettings: @escaping () -> Void,
        log: Logger
    ) {
        self.deepLinkService = deepLinkService
        self.makeScanService = makeScanService
        self.openAppSettings = openAppSettings
        self.log = log
    }
}
