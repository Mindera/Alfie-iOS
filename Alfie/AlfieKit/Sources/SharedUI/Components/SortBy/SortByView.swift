import SwiftUI

// MARK: - SortByView

public struct SortByView: View {
    @Binding private var sortBy: SortByType
    private var title: String
    private var options: [SortByItemProtocol]

    public init(sortBy: Binding<SortByType>, title: String, options: [SortByItemProtocol]) {
        _sortBy = sortBy
        self.title = title
        self.options = options
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(Constants.fontTitle)
                    .foregroundStyle(Primitives.Colours.neutrals800)
                Spacer()
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
            ScrollViewReader { reader in
                ScrollView(.horizontal) {
                    HStack(spacing: Primitives.Spacing.spacing8) {
                        ForEach(options, id: \.value) { option in
                            Button {
                                sortBy = option.value
                                withAnimation(.standardDecelerate) {
                                    reader.scrollTo(option.value, anchor: .center)
                                }
                            } label: {
                                HStack(spacing: Primitives.Spacing.spacing8) {
                                    if let icon = option.icon {
                                        icon.image
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(size: Constants.iconSize)
                                            .tint(Primitives.Colours.neutrals800)
                                            .padding(.vertical, Primitives.Spacing.spacing12)
                                            .padding(.leading, Primitives.Spacing.spacing12)
                                    }
                                    Text.build(theme.font.body.small(option.title))
                                        .foregroundStyle(Primitives.Colours.neutrals800)
                                        .padding(.trailing, Primitives.Spacing.spacing12)
                                        .padding(.vertical, Primitives.Spacing.spacing12)
                                        .padding(.leading, option.icon == nil ? Primitives.Spacing.spacing12 : 0)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: Sizing.radiusSoft)
                                        .stroke(
                                            colorForOptionBorder(option.value),
                                            lineWidth: Constants.borderLineWidth
                                        )
                                }
                            }
                            .padding(.vertical, Constants.scrollBuffer)
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Primitives.Spacing.spacing16)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func colorForOptionBorder(_ option: SortByType) -> Color {
        option == sortBy ? Primitives.Colours.neutrals800 : Primitives.Colours.neutrals100
    }

    private enum Constants {
        static let titleFontSize: CGFloat = 18
        static let borderLineWidth: CGFloat = 1
        static let iconSize: CGSize = .init(width: 16, height: 16)
        static let fontTitle: Font = DesignSystem.shared.font.body.medium.uiFont.withSize(Constants.titleFontSize).font
        static let scrollBuffer: CGFloat = 1
    }
}

#Preview {
    SortByView(sortBy: .constant(.alphaDesc), title: "Sort By", options: [])
}
