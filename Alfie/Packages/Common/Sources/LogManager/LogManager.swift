import Foundation
import os.log

// The global logManager instance is created without any loggers, make sure some are added later during the app bootstrap process
// We can't add them here because we may have loggers that use 3rd-party dependencies that are not known to this package

#if DEBUG
public let logManager: LogManagerProtocol = ProcessInfo.isRunningTests ? DummyLogManager() : LogManager()
#else
public let logManager: LogManagerProtocol = LogManager()
#endif

/// Logs a debug message by default. It'll __not__ print to Xcode's console by default. .error or .critical logLevels will cause an assertionFailure
public func log(_ message: String, level: LogLevel = .debug, file: StaticString = #fileID, line: Int = #line, printToConsole: Bool = false) {
    logManager.log(message, level: level, file: file, line: line, printToConsole: printToConsole)
}

/// Logs an error message. It'll print to Xcode's console by default. Will cause an assertionFailure if called.
public func logError(_ message: String, file: StaticString = #fileID, line: Int = #line, printToConsole: Bool = true) {
    logManager.log(message, level: .error, file: file, line: line, printToConsole: printToConsole)
}

/// Logs an error message. It'll print to Xcode's console by default.
public func logWarning(_ message: String, file: StaticString = #fileID, line: Int = #line, printToConsole: Bool = true) {
    logManager.log(message, level: .warning, file: file, line: line, printToConsole: printToConsole)
}

// MARK: - Log Manager default implementation

final class LogManager: LogManagerProtocol {
    private var loggers = [LoggerProtocol]()
    private var internalRuntimeLogs = [Log]()
    private let runtimeLogQueue = DispatchQueue(label: "runtime.log.queue")

    private let systemLogger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "",
        category: "LogManager"
    )

    public var runtimeLogs: [Log] {
        runtimeLogQueue.sync {
            internalRuntimeLogs
        }
    }

    func setLoggers(_ loggers: [LoggerProtocol]) {
        self.loggers = loggers
    }

    func log(_ message: String, level: LogLevel, file: StaticString, line: Int, printToConsole: Bool) {
        guard !loggers.isEmpty else {
            assertionFailure("Trying to log a message without any loggers having been set")
            return
        }

        // printToConsole is being ignored for now until we decide if we want to keep logging to Xcode or not
        Task {
            let log = Log(message: message, level: level, file: file, line: line)

            runtimeLogQueue.async { [weak self] in
                self?.internalRuntimeLogs.append(log)
            }

            loggers.forEach { logger in
                logger.log(log)
            }

            // TODO: Uncomment once we have a more stable API to avoid false positives by the QA team while validating
            // if [.error, .critical].contains(level) {
            //     assertionFailure(log.description)
            // }
        }
    }

    func addLogger(_ logger: LoggerProtocol) {
        loggers.append(logger)
    }
}

// MARK: - Dummy Log Manager (for unit tests)

final class DummyLogManager: LogManagerProtocol {
    let runtimeLogs = [Log]()

    func log(_ message: String, level: LogLevel, file: StaticString, line: Int, printToConsole: Bool) {}

    func setLoggers(_ loggers: [LoggerProtocol]) { }
}
