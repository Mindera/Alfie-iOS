import StyleGuide
import SwiftUI

struct AccountSectionView: View {
    private var section: AccountSection
    private var hiddenDividerTop: Bool
    private var hiddenDividerBottom: Bool

    init(for section: AccountSection, hiddenDividerTop: Bool = false, hiddenDividerBottom: Bool = false) {
        self.section = section
        self.hiddenDividerTop = hiddenDividerTop
        self.hiddenDividerBottom = hiddenDividerBottom
    }

    var body: some View {
        VStack(spacing: Spacing.space0) {
            if !hiddenDividerTop {
                ThemedDivider.horizontalThin
            }
            HStack(alignment: .center) {
                iconForImage(section.icon.image)
                Text.build(theme.font.paragraph.normal(section.title))
                Spacer()
                Icon.chevronRight.image
                    .resizable()
                    .frame(width: AccountConstants.iconSize, height: AccountConstants.iconSize)
                    .aspectRatio(contentMode: .fit)
                    .accessibilityIdentifier(AccessibilityId.actionIcon)
            }
            .frame(minHeight: AccountConstants.sectionHeight)
            if !hiddenDividerBottom {
                ThemedDivider.horizontalThin
            }
        }
    }

    private func iconForImage(_ image: Image) -> some View {
        image.resizable()
            .frame(width: AccountConstants.iconSize, height: AccountConstants.iconSize)
            .aspectRatio(contentMode: .fit)
            .accessibilityIdentifier(AccessibilityId.sectionIcon)
    }

    private enum AccountConstants {
        static let iconSize: CGFloat = Spacing.space200
        static let sectionHeight: CGFloat = 60
    }
}

private enum AccessibilityId {
    static let actionIcon = "action-icon"
    static let sectionIcon = "section-icon"
}

#Preview {
    AccountSectionView(for: .myDetails)
}
