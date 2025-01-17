import Foundation
import os.log

public struct DefaultSystemLogger: LoggerProtocol {
    private let systemLogger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "",
        category: "LogManager"
    )

    public init() { }

    public func log(_ log: Log) {
        // swiftlint:disable vertical_whitespace_between_cases
        switch log.level {
        case .debug:
            systemLogger.debug("\(log.description, privacy: .public)")
        case .info:
            systemLogger.info("\(log.description, privacy: .public)")
        case .warning:
            systemLogger.warning("\(log.description, privacy: .public)")
        case .error:
            systemLogger.error("\(log.description, privacy: .public)")
        case .critical:
            systemLogger.critical("\(log.description, privacy: .public)")
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
