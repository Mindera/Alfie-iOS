import SwiftUI

// MARK: - AccordionType

public enum AccordionType {
    case small
    case large
}

// MARK: - AccordionView

public struct AccordionView<Content: View>: View {
    private var text: String
    @Binding private var isDisabled: Bool
    private var type: AccordionType
    @State private var isOpen: Bool
    private var notFirst: Bool
    private var content: () -> Content

    public init(
        text: String,
        isOpen: Bool = false,
        type: AccordionType = .small,
        isDisabled: Binding<Bool> = .constant(false),
        notFirst: Bool = false,
        content: @escaping () -> Content
    ) {
        self.text = text
        _isDisabled = isDisabled
        self.type = type
        self.content = content
        self.isOpen = isOpen
        self.notFirst = notFirst
    }

    public var body: some View {
        VStack(spacing: theme.sizing.spacingSpacingNone) {
            if !notFirst {
                Rectangle()
                    .fill(accordianColor)
                    .frame(height: 1)
            }
            DisclosureGroup(isExpanded: $isOpen, content: { content().padding(.vertical, marginsValue) }, label: {
                HStack {
                    Text.build(theme.font.body.medium(text))
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
            return theme.sizing.spacingSpacingSm
        case .large:
            return theme.sizing.spacingSpacingMd
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    private var textColor: Color {
        isDisabled ? theme.color.contentContentPrimaryDisabled : theme.color.contentContentPrimary
    }

    private var accordianColor: Color {
        isDisabled ? theme.color.contentContentPrimaryDisabled : theme.color.contentContentTerciary
    }
}

// MARK: - MyDisclosureStyle

public struct MyDisclosureStyle: DisclosureGroupStyle {
    var isDisabled: Bool

    private var theme: DesignSystemProtocol { DesignSystem.shared }

    public func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .center) {
                    configuration.label
                    Spacer()
                    ThemedIcon(
                        .chevronDown,
                        size: .small,
                        tint: isDisabled
                            ? theme.color.contentContentPrimaryDisabled
                            : theme.color.contentContentTerciary
                    )
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
            .padding(DesignSystem.shared.sizing.spacingSpacingMd)

            AccordionView(text: "Accordian component", isDisabled: .constant(true)) {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Rhoncus, accumsan, vel interdum diam tortor cursus nam quisque ut. Blandit ut netus consequat ridiculus mi. Lacus a fermentum nec nisl consectetur molestie. Mauris mi cursus quis risus aliquam vivamus blandit. Maecenas dui odio odio aliquet.")
            }
            .padding(DesignSystem.shared.sizing.spacingSpacingMd)

            AccordionView(text: "Accordian component", type: .large) {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Rhoncus, accumsan, vel interdum diam tortor cursus nam quisque ut. Blandit ut netus consequat ridiculus mi. Lacus a fermentum nec nisl consectetur molestie. Mauris mi cursus quis risus aliquam vivamus blandit. Maecenas dui odio odio aliquet.")
            }
            .padding(DesignSystem.shared.sizing.spacingSpacingMd)

            AccordionView(text: "Accordian component", type: .large, isDisabled: .constant(true)) {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Rhoncus, accumsan, vel interdum diam tortor cursus nam quisque ut. Blandit ut netus consequat ridiculus mi. Lacus a fermentum nec nisl consectetur molestie. Mauris mi cursus quis risus aliquam vivamus blandit. Maecenas dui odio odio aliquet.")
            }
            .padding(DesignSystem.shared.sizing.spacingSpacingMd)
        }
    }
}
// swiftlint:enable line_length
