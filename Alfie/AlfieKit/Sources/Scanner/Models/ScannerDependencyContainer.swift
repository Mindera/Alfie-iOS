import AlicerceLogging
import Model

public final class ScannerDependencyContainer {
    let deepLinkService: DeepLinkServiceProtocol
    /// A factory rather than an instance: each presentation of the scanner gets its own camera
    /// session, and the previous one is released with the screen that owned it.
    let makeScanSource: () -> ScanSourceProtocol
    let log: Logger

    public init(
        deepLinkService: DeepLinkServiceProtocol,
        makeScanSource: @escaping () -> ScanSourceProtocol = { MainActor.assumeIsolated { CameraScanSource() } },
        log: Logger
    ) {
        self.deepLinkService = deepLinkService
        self.makeScanSource = makeScanSource
        self.log = log
    }
}
