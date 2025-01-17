import Common
import StyleGuide
import SwiftUI

struct LogsView: View {
    @State private var logLevelFilter: LogLevel?
    private let filters: [LogLevel?] = [nil] + LogLevel.allCases

    private var filteredLogs: [Log] {
        guard let logLevelFilter else {
            return logManager.runtimeLogs
        }

        return logManager.runtimeLogs.filter { $0.level == logLevelFilter }
    }

    var body: some View {
        VStack {
            Picker("Filter", selection: $logLevelFilter) {
                ForEach(filters, id: \.self) { filter in
                    Text.build(theme.font.small.normal(filter?.rawValue ?? "All"))
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal, Spacing.space100)

        List(filteredLogs.sortedByMostRecent, id: \.id) { log in
            preview(for: log)
        }
        .listStyle(.plain)
        .tint(Colors.primary.black)
    }

    private func preview(for log: Log) -> some View {
        DisclosureGroup(
            content: {
                VStack(alignment: .leading) {
                    Text.build(theme.font.small.normal("\(log.fileName):\(log.line)"))
                }
            },
            label: {
                HStack(spacing: Spacing.space200) {
                    icon(for: log.level)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(color(for: log.level))
                    VStack(alignment: .leading) {
                        HStack {
                            Text.build(theme.font.paragraph.bold(log.level.rawValue))
                                .foregroundStyle(color(for: log.level))
                            Text.build(theme.font.small.normal("(\(log.date.formatted(date: .omitted, time: .standard)))"))
                        }

                        Text.build(theme.font.small.normal(log.message))
                    }
                }
            }
        )
        .tint(Colors.primary.black)
    }

    private func color(for logLevel: LogLevel) -> Color {
        // swiftlint:disable vertical_whitespace_between_cases
        switch logLevel {
        case .debug,
             .info: // swiftlint:disable:this indentation_width
            return Colors.primary.black
        case .warning:
            return Colors.secondary.yellow400
        case .error:
            return Colors.secondary.red500
        case .critical:
            return Colors.secondary.red700
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    private func icon(for logLevel: LogLevel) -> Image {
        // swiftlint:disable vertical_whitespace_between_cases
        switch logLevel {
        case .debug,
             .info: // swiftlint:disable:this indentation_width
            return Image(systemName: "info.circle")
        case .warning:
            return Image(systemName: "exclamationmark.triangle")
        case .error:
            return Image(systemName: "exclamationmark.circle")
        case .critical:
            return Image(systemName: "exclamationmark.3")
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

#Preview {
    LogsView()
}
