import SwiftUI

// MARK: - SortByView

public struct SortByView: View {
    @Binding private var sortBy: SortByType
    private var title: String
    private var options: [SortByItemProtocol]

    init(sortBy: Binding<SortByType>, title: String, options: [SortByItemProtocol]) {
        _sortBy = sortBy
        self.title = title
        self.options = options
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(Constants.fontTitle)
                    .foregroundStyle(Colors.primary.mono900)
                Spacer()
            }
            .padding(.horizontal, Spacing.space200)
            ScrollViewReader { reader in
                ScrollView(.horizontal) {
                    HStack(spacing: Spacing.space075) {
                        ForEach(options, id: \.value) { option in
                            Button {
                                sortBy = option.value
                                withAnimation(.standardDecelerate) {
                                    reader.scrollTo(option.value, anchor: .center)
                                }
                            } label: {
                                HStack(spacing: Spacing.space100) {
                                    if let icon = option.icon {
                                        icon.image
                                            .resizable()
                                            .renderingMode(.template)
                                            .tint(Colors.primary.mono900)
                                            .frame(size: Constants.iconSize)
                                            .aspectRatio(contentMode: .fit)
                                            .padding(.vertical, Spacing.space150)
                                            .padding(.leading, Spacing.space150)
                                    }
                                    Text.build(theme.font.small.bold(option.title))
                                        .foregroundStyle(Colors.primary.mono900)
                                        .padding(.trailing, Spacing.space150)
                                        .padding(.vertical, Spacing.space150)
                                        .padding(.leading, option.icon == nil ? Spacing.space150 : 0)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: CornerRadius.s)
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
                    .padding(.horizontal, Spacing.space200)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func colorForOptionBorder(_ option: SortByType) -> Color {
        option == sortBy ? Colors.primary.mono900 : Colors.primary.mono100
    }

    private enum Constants {
        static let titleFontSize: CGFloat = 18
        static let borderLineWidth: CGFloat = 1
        static let iconSize: CGSize = .init(width: 16, height: 16)
        static let fontTitle: Font = ThemeProvider.shared.font.paragraph.normal.withSize(Constants.titleFontSize).font
        static let scrollBuffer: CGFloat = 1
    }
}

#Preview {
    SortByView(sortBy: .constant(.mostPopular), title: "Sort By", options: [])
}
