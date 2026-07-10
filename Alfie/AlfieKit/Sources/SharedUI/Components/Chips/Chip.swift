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
    private let configuration: ChipConfiguration

    public init(configuration: ChipConfiguration) {
        self.configuration = configuration
    }

    private var style: ChipStyle {
        ChipStyle(
            type: configuration.type,
            isSelected: configuration.isSelected,
            isDisabled: configuration.isDisabled,
            counter: configuration.counter
        )
    }

    public var body: some View {
        let style = self.style
        return ZStack {
            RoundedRectangle(cornerRadius: Sizing.radiusRounded)
                .stroke(style.borderColor, lineWidth: style.borderWidth)
                .background(RoundedRectangle(cornerRadius: Sizing.radiusRounded).fill(style.backgroundColor))
            HStack(spacing: Primitives.Spacing.spacing8) {
                Text.build(theme.font.body.small(configuration.label))
                    .foregroundStyle(style.textColor)
                if let counterLabel = style.counterLabel {
                    Text.build(theme.font.body.small(counterLabel))
                        .foregroundStyle(style.textColor)
                }
                if configuration.showCloseButton {
                    Button(action: {
                        configuration.onCloseTap?()
                    }, label: {
                        HStack(spacing: Primitives.Spacing.spacing0) {
                            Icon.close.image
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: ChipStyle.closeWidth, height: ChipStyle.closeHeight)
                                .foregroundStyle(style.textColor)
                        }
                        .frame(maxHeight: .infinity)
                    })
                    .disabled(configuration.isDisabled)
                }
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, Primitives.Spacing.spacing16)
        .frame(height: style.height)
    }
}

/// Resolves a `Chip`'s visual styling from its state, sourced from design tokens.
/// Extracted from `Chip` so the state→token mapping is unit-testable without snapshots.
struct ChipStyle {
    private enum Constants {
        static let heightSmall = 36.0
        static let heightLarge = 44.0
        static let closeWidth = 12.0
        static let closeHeight = 12.0
        static let borderSelected = 2.0
        static let maxCounter: Int = 99
    }

    // Close-icon dimensions are fixed layout constants (state-independent), so they are exposed
    // statically rather than as instance properties of this state resolver.
    static let closeWidth = Constants.closeWidth
    static let closeHeight = Constants.closeHeight

    let type: ChipConfiguration.ChipType
    let isSelected: Bool
    let isDisabled: Bool
    let counter: Int?

    var borderColor: Color {
        if isDisabled {
            // surfaceForegroundPrimary is the only Theme alias mapping to neutrals100 (grill decision).
            return Theme.surfaceForegroundPrimary
        } else if isSelected {
            return Theme.contentContentPrimary
        } else {
            return Theme.borderSoft
        }
    }

    var textColor: Color {
        if isDisabled {
            return Theme.contentContentPrimaryDisabled
        } else {
            // No Theme alias maps to neutrals600, so this remains a raw primitive.
            return Primitives.Colours.neutrals600
        }
    }

    var backgroundColor: Color {
        if isDisabled {
            return Theme.surfaceForegroundPrimary
        } else {
            return Theme.surfaceBackgroundPrimary
        }
    }

    var borderWidth: CGFloat {
        if isSelected {
            return Constants.borderSelected
        } else {
            return CGFloat(Primitives.Border.borderWeightDefault)
        }
    }

    var height: CGFloat {
        // swiftlint:disable vertical_whitespace_between_cases
        switch type {
        case .small:
            return Constants.heightSmall
        case .large:
            return Constants.heightLarge
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    var counterLabel: String? {
        guard let counter else {
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
