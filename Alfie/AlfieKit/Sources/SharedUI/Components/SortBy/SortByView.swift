import SwiftUI

// MARK: - SortByView

public struct SortByView: View {
    /// Optional because no sort is pre-selected — the BFF's own default applies until the user
    /// picks one, and a radio group cannot otherwise represent "nothing chosen".
    @Binding private var sortBy: SortByType?
    /// `nil` omits the in-content heading, for hosts that already title the surface — the refine
    /// sub-screen carries "Sort By" in its navigation bar and would otherwise show it twice.
    private var title: String?
    private var options: [SortByItemProtocol]

    public init(sortBy: Binding<SortByType?>, title: String?, options: [SortByItemProtocol]) {
        _sortBy = sortBy
        self.title = title
        self.options = options
    }

    public var body: some View {
        VStack(alignment: .leading) {
            if let title {
                HStack {
                    Text.build(theme.font.body.medium(title))
                        .foregroundStyle(theme.color.contentContentPrimary)
                    Spacer()
                }
                .padding(.horizontal, theme.sizing.spacingSpacingMd)
            }
            ScrollViewReader { reader in
                ScrollView(.horizontal) {
                    HStack(spacing: theme.sizing.spacingSpacingXs) {
                        ForEach(options, id: \.value) { option in
                            Button {
                                sortBy = option.value
                                withAnimation(.standardDecelerate) {
                                    reader.scrollTo(option.value, anchor: .center)
                                }
                            } label: {
                                HStack(spacing: theme.sizing.spacingSpacingXs) {
                                    if let icon = option.icon {
                                        icon.image
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(size: Constants.iconSize)
                                            .foregroundStyle(theme.color.contentContentPrimary)
                                            .padding(.vertical, theme.sizing.spacingSpacingSm)
                                            .padding(.leading, theme.sizing.spacingSpacingSm)
                                    }
                                    Text.build(theme.font.body.small(option.title))
                                        .foregroundStyle(theme.color.contentContentPrimary)
                                        .padding(.trailing, theme.sizing.spacingSpacingSm)
                                        .padding(.vertical, theme.sizing.spacingSpacingSm)
                                        .padding(.leading, option.icon == nil ? theme.sizing.spacingSpacingSm : 0)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: theme.sizing.radiusSoft)
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
                    .padding(.horizontal, theme.sizing.spacingSpacingMd)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func colorForOptionBorder(_ option: SortByType) -> Color {
        option == sortBy ? theme.color.contentContentPrimary : theme.color.borderSoft
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
