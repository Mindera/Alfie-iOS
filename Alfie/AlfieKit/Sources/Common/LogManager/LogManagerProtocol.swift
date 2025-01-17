import Foundation

public protocol LogManagerProtocol {
    var runtimeLogs: [Log] { get }

    func log(_ message: String, level: LogLevel, file: StaticString, line: Int, printToConsole: Bool)

    func setLoggers(_ loggers: [LoggerProtocol])
}
