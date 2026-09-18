import SharedUI
import SwiftUI

struct AccountSectionView: View {
    private let section: AccountSection

    init(for section: AccountSection) {
        self.section = section
    }

    var body: some View {
        HStack(spacing: Primitives.Spacing.spacing8) {
            section.icon.image
                .resizable()
                .scaledToFit()
                .frame(width: AccountConstants.iconSize, height: AccountConstants.iconSize)
                .accessibilityIdentifier(AccessibilityId.sectionIcon)

            Text.build(theme.font.body.medium(section.title))
                .foregroundStyle(Theme.contentContentPrimary)

            Spacer()
        }
        .padding(.vertical, Primitives.Spacing.spacing12)
        .frame(minHeight: AccountConstants.sectionHeight)
    }

    private enum AccountConstants {
        static let iconSize: CGFloat = Sizing.iconsIconMedium
        static let sectionHeight: CGFloat = 48
    }
}

private enum AccessibilityId {
    static let sectionIcon = "section-icon"
}

#Preview {
    AccountSectionView(for: .personalInformation)
}
