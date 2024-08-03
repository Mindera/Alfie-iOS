import SwiftUI

public struct ChipConfiguration {
    public enum ChipType {
        case small
        case large
    }

    public let type: ChipType
    public let label: String
    public let showCloseButton: Bool
    @Binding public var isDisabled: Bool
    @Binding public var isSelected: Bool
    public var counter: Int?
    public let onCloseTap: (() -> Void)?

    public init(
        type: ChipType,
        label: String,
        counter: Int? = nil,
        showCloseButton: Bool = false,
        isDisabled: Binding<Bool> = .constant(false),
        isSelected: Binding<Bool> = .constant(false),
        onCloseTap: (() -> Void)? = nil
    ) {
        self.type = type
        self.label = label
        self.counter = counter
        self.showCloseButton = showCloseButton
        self._isDisabled = isDisabled
        self._isSelected = isSelected
        self.onCloseTap = onCloseTap
    }

    public static func small(label: String, onCloseTap: (() -> Void)? = nil) -> ChipConfiguration {
        ChipConfiguration(type: .small, label: label, showCloseButton: onCloseTap != nil, onCloseTap: onCloseTap)
    }

    public static func large(label: String, onCloseTap: (() -> Void)? = nil) -> ChipConfiguration {
        ChipConfiguration(type: .large, label: label, showCloseButton: onCloseTap != nil, onCloseTap: onCloseTap)
    }
}

public struct Chip: View {
    private enum Constants {
        static let heightSmall = 36.0
        static let heightLarge = 44.0
        static let closeWidth = 12.0
        static let closeHeight = 12.0
        static let borderNormal = 1.0
        static let borderSelected = 2.0
        static let maxCounter: Int = 99
    }

    private let configuration: ChipConfiguration

    public init(configuration: ChipConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CornerRadius.full)
                .stroke(borderColor, lineWidth: borderWidth)
                .background(RoundedRectangle(cornerRadius: CornerRadius.full).fill(backgroundColor))
            HStack(spacing: Spacing.space100) {
                Text.build(theme.font.small.normal(configuration.label))
                    .foregroundColor(textColor)
                if let counterLabel {
                    Text.build(theme.font.small.normal(counterLabel))
                        .foregroundColor(textColor)
                }
                if configuration.showCloseButton {
                    Button(action: {
                        configuration.onCloseTap?()
                    }, label: {
                        HStack(spacing: Spacing.space0) {
                            Icon.close.image
                                .renderingMode(.template)
                                .resizable()
                                .foregroundStyle(textColor)
                                .frame(width: Constants.closeWidth, height: Constants.closeHeight)
                        }
                        .frame(maxHeight: .infinity)
                    })
                    .disabled(configuration.isDisabled)
                }
            }
            .padding(.horizontal, Spacing.space200)
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, Spacing.space200)
        .frame(height: chipHeight)
    }

    private var borderColor: Color {
        if configuration.isDisabled {
            return Colors.primary.mono100
        } else if configuration.isSelected {
            return Colors.primary.mono900
        } else {
            return Colors.primary.mono200
        }
    }

    private var textColor: Color {
        if configuration.isDisabled {
            return Colors.primary.mono300
        } else {
            return Colors.primary.mono700
        }
    }

    private var backgroundColor: Color {
        if configuration.isDisabled {
            return Colors.primary.mono050
        } else {
            return Colors.primary.white
        }
    }

    private var borderWidth: CGFloat {
        if configuration.isSelected {
            return Constants.borderSelected
        } else {
            return Constants.borderNormal
        }
    }

    private var chipHeight: CGFloat {
        // swiftlint:disable vertical_whitespace_between_cases
        switch configuration.type {
        case .small:
            return Constants.heightSmall
        case .large:
            return Constants.heightLarge
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    private var counterLabel: String? {
        guard let counter = configuration.counter else {
            return nil
        }
        return counter > Constants.maxCounter ? "\(Constants.maxCounter)+" : "\(counter)"
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Small")
        HStack(spacing: 20) {
            Chip(configuration: .init(type: .small, label: "Normal", counter: 1))
            Chip(configuration: .init(type: .small, label: "Closeable", showCloseButton: true))
        }
        .padding()
        HStack(spacing: 20) {
            Chip(
                configuration: .init(
                    type: .small,
                    label: "Disabled",
                    showCloseButton: false,
                    isDisabled: .constant(true)
                )
            )
            Chip(
                configuration: .init(
                    type: .small,
                    label: "Disabled",
                    showCloseButton: true,
                    isDisabled: .constant(true)
                )
            )
        }
        .padding()
        HStack(spacing: 20) {
            Chip(
                configuration: .init(
                    type: .small,
                    label: "Selected",
                    showCloseButton: false,
                    isSelected: .constant(true)
                )
            )
            Chip(
                configuration: .init(
                    type: .small,
                    label: "Selected",
                    showCloseButton: true,
                    isSelected: .constant(true)
                )
            )
        }
        .padding()

        Text("Large")
        HStack(spacing: 20) {
            Chip(configuration: .init(type: .large, label: "Normal", counter: 1000))
            Chip(configuration: .init(type: .large, label: "Closeable", showCloseButton: true))
        }
        .padding()
        HStack(spacing: 20) {
            Chip(
                configuration: .init(
                    type: .large,
                    label: "Disabled",
                    showCloseButton: false,
                    isDisabled: .constant(true)
                )
            )
            Chip(
                configuration: .init(
                    type: .large,
                    label: "Disabled",
                    showCloseButton: true,
                    isDisabled: .constant(true)
                )
            )
        }
        .padding()
        HStack(spacing: 20) {
            Chip(
                configuration: .init(
                    type: .large,
                    label: "Selected",
                    showCloseButton: false,
                    isSelected: .constant(true)
                )
            )
            Chip(
                configuration: .init(
                    type: .large, label: "Selected", showCloseButton: true, isSelected: .constant(true)
                )
            )
        }
        .padding()
        Spacer()
    }
    .padding()
}
