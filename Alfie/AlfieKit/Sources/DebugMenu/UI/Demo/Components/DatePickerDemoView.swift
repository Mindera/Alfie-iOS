import SharedUI
import SwiftUI

private enum DatePickerType: String, CaseIterable {
    case graphical = "Expanded"
    case compact = "Compact"
    case wheel = "Wheel (legacy)"
}

struct DatePickerDemoView: View {
    @State private var hourSelection: Date = .now
    @State private var dateSelection: Date = .now
    @State private var dateAndHourSelection: Date = .now
    @State private var datePickerType: DatePickerType = .graphical

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.space250) {
                DemoHelper.demoSectionHeader(title: "Date Picker")

                Picker("Date Picker Style", selection: $datePickerType) {
                    ForEach(DatePickerType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom, Spacing.space200)

                if datePickerType == .wheel {
                    if datePickerType == .wheel {
                        VStack(alignment: .leading) {
                            Text.build(theme.font.small.bold("Date Picker"))
                            ThemedDivider.horizontalThin
                        }
                    }
                    DatePicker("", selection: $dateSelection, displayedComponents: .date)
                        .labelsHidden()
                        .modifier(DatePickerModifier(type: datePickerType))
                        .tint(Colors.primary.black)

                    if datePickerType == .wheel {
                        VStack(alignment: .leading) {
                            Text.build(theme.font.small.bold("Time Picker"))
                            ThemedDivider.horizontalThin
                        }
                    }
                    DatePicker("", selection: $dateSelection, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .modifier(DatePickerModifier(type: datePickerType))
                        .tint(Colors.primary.black)
                }

                if datePickerType == .wheel {
                    VStack(alignment: .leading) {
                        Text.build(theme.font.small.bold("Date & Time Picker"))
                        ThemedDivider.horizontalThin
                    }
                }
                DatePicker("", selection: $dateAndHourSelection, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .modifier(DatePickerModifier(type: datePickerType))
                    .tint(Colors.primary.black)
                    .padding(.horizontal, Spacing.space200)
            }
            .padding(.horizontal, Spacing.space200)
        }
        .environment(\.locale, Locale(identifier: "en_AU"))
    }
}

private struct DatePickerModifier: ViewModifier {
    private var type: DatePickerType

    init(type: DatePickerType) {
        self.type = type
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        switch type {
        case .graphical:
            content
                .datePickerStyle(.graphical)
                .frame(width: 320, height: 420, alignment: .top)

        case .wheel:
            content
                .datePickerStyle(.wheel)

        case .compact:
            content
                .datePickerStyle(.compact)
        }
    }
}

#Preview {
    DatePickerDemoView()
}
