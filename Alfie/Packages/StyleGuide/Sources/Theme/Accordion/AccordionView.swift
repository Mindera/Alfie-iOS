import SwiftUI

// MARK: - AccordionType

enum AccordionType {
    case small
    case large
}

// MARK: - AccordionView

struct AccordionView<Content: View>: View {
    private var text: String
    @Binding private var isDisabled: Bool
    private var type: AccordionType
    @State private var isOpen: Bool
    private var notFirst: Bool
    private var content: () -> Content

    init(text: String, isOpen: Bool = false, type: AccordionType = .small, isDisabled: Binding<Bool> = .constant(false), notFirst: Bool = false, content: @escaping () -> Content) {
        self.text = text
        _isDisabled = isDisabled
        self.type = type
        self.content = content
        self.isOpen = isOpen
        self.notFirst = notFirst
    }

    var body: some View {
        VStack(spacing: Spacing.space0) {
            if !notFirst {
                Rectangle()
                    .fill(accordianColor)
                    .frame(height: 1)
            }
            DisclosureGroup(isExpanded: $isOpen, content: { content().padding(.vertical, marginsValue) }, label: {
                HStack {
                    Text.build(theme.font.paragraph.normal(text))
                        .foregroundStyle(textColor)
                }
                .padding(.vertical, marginsValue)
            })
            .disclosureGroupStyle(MyDisclosureStyle(isDisabled: isDisabled))
            .allowsHitTesting(!isDisabled)
            .tint(textColor)
            Rectangle()
                .fill(accordianColor)
                .frame(height: 1)
        }
    }

    private var marginsValue: CGFloat {
        // swiftlint:disable vertical_whitespace_between_cases
        switch type {
        case .small:
            return Spacing.space150
        case .large:
            return Spacing.space200
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    private var textColor: Color {
        isDisabled ? Colors.primary.mono700 : Colors.primary.mono900
    }

    private var accordianColor: Color {
        isDisabled ? Colors.primary.mono200 : Colors.primary.mono500
    }
}

// MARK: - MyDisclosureStyle

struct MyDisclosureStyle: DisclosureGroupStyle {
    var isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .center) {
                    configuration.label
                    Spacer()
                    Icon.chevronDown.image
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(isDisabled ? Colors.primary.mono200 : Colors.primary.mono500)
                        .rotationEffect(.degrees(configuration.isExpanded ? 0 : -90))
                        .animation(.easeInOut(duration: 0.3), value: configuration.isExpanded)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}

// swiftlint:disable line_length
#Preview {
    ScrollView {
        VStack {
            AccordionView(text: "Accordian component") {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Rhoncus, accumsan, vel interdum diam tortor cursus nam quisque ut. Blandit ut netus consequat ridiculus mi. Lacus a fermentum nec nisl consectetur molestie. Mauris mi cursus quis risus aliquam vivamus blandit. Maecenas dui odio odio aliquet.")
            }
            .padding(Spacing.space200)

            AccordionView(text: "Accordian component", isDisabled: .constant(true)) {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Rhoncus, accumsan, vel interdum diam tortor cursus nam quisque ut. Blandit ut netus consequat ridiculus mi. Lacus a fermentum nec nisl consectetur molestie. Mauris mi cursus quis risus aliquam vivamus blandit. Maecenas dui odio odio aliquet.")
            }
            .padding(Spacing.space200)

            AccordionView(text: "Accordian component", type: .large) {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Rhoncus, accumsan, vel interdum diam tortor cursus nam quisque ut. Blandit ut netus consequat ridiculus mi. Lacus a fermentum nec nisl consectetur molestie. Mauris mi cursus quis risus aliquam vivamus blandit. Maecenas dui odio odio aliquet.")
            }
            .padding(Spacing.space200)

            AccordionView(text: "Accordian component", type: .large, isDisabled: .constant(true)) {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Rhoncus, accumsan, vel interdum diam tortor cursus nam quisque ut. Blandit ut netus consequat ridiculus mi. Lacus a fermentum nec nisl consectetur molestie. Mauris mi cursus quis risus aliquam vivamus blandit. Maecenas dui odio odio aliquet.")
            }
            .padding(Spacing.space200)
        }
    }
}
// swiftlint:enable line_length
