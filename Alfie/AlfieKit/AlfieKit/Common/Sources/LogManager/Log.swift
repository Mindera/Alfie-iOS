import Foundation

public struct Log: Identifiable {
    public let id = UUID()
    public let message: String
    public let level: LogLevel
    public let file: StaticString
    public let line: Int
    public let date: Date

    public var formattedDate: String {
        date.formatted(date: .numeric, time: .shortened)
    }

    public var fileName: String {
        Bundle.filename(fileID: file)
    }

    public var description: String {
        "[\(level.rawValue)] [\(fileName):\(line)] [\(formattedDate)] > \(message)"
    }

    init(message: String, level: LogLevel, file: StaticString, line: Int, date: Date = .init()) {
        self.message = message
        self.level = level
        self.file = file
        self.line = line
        self.date = date
    }
}

public extension Collection where Element == Log {
    var sortedByMostRecent: [Log] {
        sorted { $0.date > $1.date }
    }
}
