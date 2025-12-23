import AlicerceLogging

private(set) var log: Logger = Log.DummyLogger()

public enum SharedUILogger {
    public static func set(logger: Logger) {
        log = logger
    }
}
