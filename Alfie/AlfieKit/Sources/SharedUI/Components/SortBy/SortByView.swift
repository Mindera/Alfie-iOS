import SwiftUI

// MARK: - SortByView

public struct SortByView: View {
    /// Optional because no sort is pre-selected — the BFF's own default applies until the user
    /// picks one, and a radio group cannot otherwise represent "nothing chosen".
    @Binding private var sortBy: SortByType?
    private var title: String
    private var options: [SortByItemProtocol]

    public init(sortBy: Binding<SortByType?>, title: String, options: [SortByItemProtocol]) {
        _sortBy = sortBy
        self.title = title
        self.options = options
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text.build(theme.font.body.medium(title))
                    .foregroundStyle(Theme.contentContentPrimary)
                Spacer()
            }
            .padding(.horizontal, theme.spacing.space200)
            ScrollViewReader { reader in
                ScrollView(.horizontal) {
                    HStack(spacing: theme.spacing.space100) {
                        ForEach(options, id: \.value) { option in
                            Button {
                                sortBy = option.value
                                withAnimation(.standardDecelerate) {
                                    reader.scrollTo(option.value, anchor: .center)
                                }
                            } label: {
                                HStack(spacing: theme.spacing.space100) {
                                    if let icon = option.icon {
                                        icon.image
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(size: Constants.iconSize)
                                            .foregroundStyle(Theme.contentContentPrimary)
                                            .padding(.vertical, theme.spacing.space150)
                                            .padding(.leading, theme.spacing.space150)
                                    }
                                    Text.build(theme.font.body.small(option.title))
                                        .foregroundStyle(Theme.contentContentPrimary)
                                        .padding(.trailing, theme.spacing.space150)
                                        .padding(.vertical, theme.spacing.space150)
                                        .padding(.leading, option.icon == nil ? theme.spacing.space150 : 0)
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
                    .padding(.horizontal, theme.spacing.space200)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func colorForOptionBorder(_ option: SortByType) -> Color {
        option == sortBy ? Theme.contentContentPrimary : Theme.borderSoft
    }

    private enum Constants {
        static let borderLineWidth: CGFloat = 1
        static let iconSize: CGSize = .init(width: 16, height: 16)
        static let scrollBuffer: CGFloat = 1
    }
}

#Preview {
    SortByView(sortBy: .constant(nil), title: "Sort By", options: [])
}
