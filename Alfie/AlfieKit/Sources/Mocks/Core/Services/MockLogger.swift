import AlicerceLogging

/// Records log calls so a test can wait on one. Useful where the code under test handles a failure
/// silently — the log is then the only observable point that happens after the handling.
public final class MockLogger: Logger {
    public init() { }

    public var onLogCalled: ((Log.Level, String) -> Void)?
    public func log(
        level: Log.Level,
        message: @autoclosure () -> String,
        file: StaticString,
        line: Int,
        function: StaticString
    ) {
        // Evaluated unconditionally, as `Log.DummyLogger` does, so message interpolation still runs.
        let text = message()
        onLogCalled?(level, text)
    }
}
