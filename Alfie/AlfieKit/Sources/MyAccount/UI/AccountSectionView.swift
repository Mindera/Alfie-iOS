import AccessibilityIdentifiers
import SharedUI
import SwiftUI

struct AccountSectionView: View {
    private let section: AccountSection

    init(for section: AccountSection) {
        self.section = section
    }

    var body: some View {
        HStack(spacing: theme.sizing.spacingSpacingXs) {
            section.icon.image
                .resizable()
                .scaledToFit()
                .frame(width: AccountConstants.iconSize, height: AccountConstants.iconSize)
                .accessibilityIdentifier(AccessibilityID.Account.sectionIcon)

            Text.build(theme.font.body.medium(section.title))
                .foregroundStyle(theme.color.contentContentPrimary)

            Spacer()
        }
        .padding(.vertical, theme.sizing.spacingSpacingSm)
        .frame(minHeight: AccountConstants.sectionHeight)
    }

    private enum AccountConstants {
        static var iconSize: CGFloat { DesignSystem.shared.sizing.iconsIconMedium }
        static let sectionHeight: CGFloat = 48
    }
}

#Preview {
    AccountSectionView(for: .personalInformation)
}
