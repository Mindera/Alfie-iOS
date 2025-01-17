import SwiftUI

public struct TabControl: View {
    public struct TabOption: Hashable {
        let title: String
        let image: Image?
        let accessibilityId: String?

        public init(title: String, image: Image? = nil, accessibilityId: String? = nil) {
            self.title = title
            self.image = image
            self.accessibilityId = accessibilityId
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(title)
        }
    }

    public enum Theme: CaseIterable {
        case light
        case dark

        // swiftlint:disable vertical_whitespace_between_cases
        var outerLineColor: Color {
            switch self {
            case .light:
                return Colors.primary.mono200
            case .dark:
                return Colors.primary.mono900
            }
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    public enum Configuration {
        /// Left aligned, scrollable
        case intrisicSize(itemSpacing: CGFloat = Spacing.space200)
        /// Center aligned, non-scrollable
        case fixedSize(horizontalMargins: CGFloat = Spacing.space0)

        // swiftlint:disable vertical_whitespace_between_cases
        var itemSpacing: CGFloat {
            switch self {
            case .intrisicSize(let itemSpacing):
                itemSpacing
            case .fixedSize:
                Spacing.space0
            }
        }

        var isIntrisicSize: Bool {
            switch self {
            case .intrisicSize:
                true
            case .fixedSize:
                false
            }
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    enum Constants {
        static let outerLineHeight: CGFloat = 4
        static let innerLineHeight: CGFloat = 2
        static let itemHeight: CGFloat = 44
        static let imageSize: CGFloat = 16
        static let innerLineColor = Colors.primary.mono050
        static let selectedItemFontColor = Colors.primary.mono900
        static let unselectedItemFontColor = Colors.primary.mono500
        static let matchedGeometryEffectID = "tabControl_underline"
    }

    private let options: [TabOption]
    private let theme: Theme
    private let configuration: Configuration
    @Binding private var currentIndex: Int
    @Namespace private var namespace

    public init(theme: Theme, configuration: Configuration, options: [TabOption], currentIndex: Binding<Int>) {
        self.theme = theme
        self.configuration = configuration
        self.options = options
        self._currentIndex = currentIndex
    }

    public init(theme: Theme, configuration: Configuration, options: [String], currentIndex: Binding<Int>) {
        self.init(
            theme: theme,
            configuration: configuration,
            options: options.map { TabOption(title: $0) },
            currentIndex: currentIndex
        )
    }

    public var body: some View {
        tabControlSliderView(scrollable: configuration.isIntrisicSize)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(AccessibilityId.component)
    }

    @ViewBuilder
    private func tabControlSliderView(scrollable: Bool) -> some View {
        if scrollable {
            ScrollViewReader { reader in
                ScrollView(.horizontal, showsIndicators: false) {
                    tabControlItemsView
                        .onChange(of: currentIndex) { newValue in
                            withAnimation(.standardDecelerate) {
                                reader.scrollTo(newValue, anchor: .center)
                            }
                        }
                }
            }
        } else {
            tabControlItemsView
        }
    }

    private var tabControlItemsView: some View {
        HStack(alignment: .center, spacing: configuration.itemSpacing) {
            if !configuration.isIntrisicSize {
                Spacer(minLength: Spacing.space0)
            }
            ForEach(Array(options.enumerated()), id: \.0) { index, value in
                Button {
                    withAnimation(.standardDecelerate) {
                        currentIndex = index
                    }
                } label: {
                    HStack {
                        value.image?
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Constants.imageSize, height: Constants.imageSize)

                        Text.build(theme.font.paragraph.bold(value.title))
                            .lineLimit(1)
                    }
                    .foregroundStyle(
                        currentIndex == index ? Constants.selectedItemFontColor : Constants.unselectedItemFontColor
                    )
                    .overlay {
                        if currentIndex == index {
                            VStack(spacing: Spacing.space0) {
                                Spacer()
                                ThemedDivider(
                                    configuration: .init(
                                        orientation: .horizontal,
                                        thickness: Constants.outerLineHeight,
                                        color: theme.outerLineColor
                                    )
                                )
                                .cornerRadius(CornerRadius.xxs)
                                ThemedDivider(
                                    configuration: .init(
                                        orientation: .horizontal,
                                        thickness: Constants.outerLineHeight / 2,
                                        color: theme.outerLineColor
                                    )
                                )
                                .padding(.top, -Constants.outerLineHeight / 2)
                            }
                            .frame(height: Constants.itemHeight)
                            .matchedGeometryEffect(id: Constants.matchedGeometryEffectID, in: namespace)
                            .padding(.bottom, Constants.innerLineHeight * 2)
                        }
                    }
                    .tint(.black)
                }
                .id(index)
                .frame(width: itemFixedWidth)
                .accessibilityIdentifier(AccessibilityId.item)
                .if(
                    currentIndex == index,
                    whenTrue: { tab in tab.accessibilityAddTraits(.isSelected) },
                    whenFalse: { tab in tab.accessibilityRemoveTraits(.isSelected) }
                )
            }

            Spacer(minLength: Spacing.space0)
        }
        .padding(.vertical, Spacing.space200)
        .padding(.horizontal, configuration.itemSpacing)
        .background {
            VStack {
                Spacer()
                ThemedDivider(
                    configuration: .init(
                        orientation: .horizontal,
                        thickness: Constants.innerLineHeight,
                        color: Constants.innerLineColor
                    )
                )
            }
            .frame(height: Constants.itemHeight)
            // this way even with the elastic / bounce effect of the scrollView, the line will always be there
            .frame(minWidth: configuration.isIntrisicSize ? UIScreen.main.bounds.width * 2 : 0)
        }
        .animation(.standardDecelerate, value: currentIndex)
    }

    private var itemFixedWidth: CGFloat? {
        // swiftlint:disable vertical_whitespace_between_cases
        switch configuration {
        case .fixedSize(let horizontalMargins):
            UIScreen.main.bounds.width / CGFloat(options.count) - (horizontalMargins * 2)
        case .intrisicSize:
            nil
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

// MARK: - Accessibility

private enum AccessibilityId {
    static let component = "tab-component"
    static let item = "tab-item"
}

#Preview("Intrinsic Size") {
    TabControl(
        theme: .light,
        configuration: .intrisicSize(itemSpacing: Spacing.space200),
        options: ["Option1", "Option2", "Option3"],
        currentIndex: .constant(0)
    )
}

#Preview("Fixed Size") {
    TabControl(
        theme: .dark,
        configuration: .fixedSize(horizontalMargins: Spacing.space100),
        options: ["Option1", "Option2", "Option3"],
        currentIndex: .constant(0)
    )
}
