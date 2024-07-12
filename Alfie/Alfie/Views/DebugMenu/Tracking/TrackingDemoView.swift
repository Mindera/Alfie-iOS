import Models
import StyleGuide
import SwiftUI

struct TrackingDemoView: View {
    private let trackedEvents: [TrackedEvent]

    init(trackedEvents: [TrackedEvent]) {
        self.trackedEvents = trackedEvents
    }

    var body: some View {
        DemoHelper.demoSectionHeader(title: "Tracked Events")
            .padding(.horizontal, Spacing.space200)
            .padding(.bottom, Spacing.space200)
        VStack {
            if trackedEvents.isEmpty {
                Text.build(theme.font.small.normal("No Events Triggered"))
            } else {
                ScrollView {
                    ForEach(trackedEvents.reversed(), id: \.self) { trackedEvent in
                        VStack(alignment: .leading) {
                            Spacer().frame(height: 20)
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text.build(theme.font.paragraph.bold("Event Key:"))
                                    Text.build(theme.font.paragraph.bold(trackedEvent.name ?? ""))
                                    Text.build(
                                        theme.font.paragraph.normal(
                                        "(" + trackedTime(from: trackedEvent.trackedDate) + ")"
                                        )
                                    )
                                }
                                HStack {
                                    Text.build(theme.font.small.normal("Providers:"))
                                    Text.build(
                                        theme.font.small.normal(
                                            (
                                                trackedEvent
                                                    .providers
                                                    .map { $0.replacingOccurrences(of: "com.", with: "").capitalized }
                                                    .joined(separator: " ")
                                            )
                                        )
                                    )
                                }
                            }
                            Spacer().frame(height: 20)
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, Spacing.space200)
            }
        }
    }

    private func trackedTime(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
