import AlicerceLogging

private(set) var log: Logger = Log.DummyLogger()

public struct StyleGuideLogger {
    public static func setStyleGuideLogger(logger: Logger) {
        log = logger
    }
}
