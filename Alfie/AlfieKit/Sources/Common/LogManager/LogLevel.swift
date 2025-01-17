/// Defines different levels that allow us to categorize and filter log messages
public enum LogLevel: String, CaseIterable {
    /// Use this level to print generic debug messages that can help trace issues. This is the default log level. It won't be persisted after the app is closed.
    case debug
    /// Use this level to print important messages that identify specific flows of use cases inside the app. This will be persisted after the app is closed, but for a very limited amount of time.
    case info
    /// Use this level to print warning messages, like a potential error or dangerous but not critical flow. This will be persisted after the app is closed (until the system needs to free up storage)
    case warning
    /// Use this level to print error messages, like unexpected results or catch blocks. This will be persisted after the app is closed (until the system needs to free up storage)
    case error
    /// Use this level to print critical messages, like when the app reaches an unexpected state. This will be persisted after the app is closed (until the system needs to free up storage)
    case critical

    public var rawValue: String {
        "\(self)".capitalized
    }
}
