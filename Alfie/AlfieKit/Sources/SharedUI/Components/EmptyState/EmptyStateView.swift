import SwiftUI

public struct EmptyStateView: View {
    private let icon: Icon
    private let title: String
    private let message: String?

    public init(icon: Icon, title: String, message: String? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: Sizing.spacingSpacingMd) {
            ThemedIcon(icon, tint: Theme.contentContentPrimary)
            VStack(spacing: Sizing.spacingSpacing2xs) {
                Text.build(theme.font.body.medium(title))
                    .foregroundStyle(Theme.contentContentPrimary)
                if let message {
                    Text.build(theme.font.body.medium(message))
                        .foregroundStyle(Theme.contentContentTerciary)
                }
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, Sizing.spacingSpacingXl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Title") {
    EmptyStateView(icon: .bag, title: "Your bag is empty.")
}

#Preview("Title and message") {
    EmptyStateView(
        icon: .heart,
        title: "Your wishlist is empty.",
        message: "Tap this icon in the products you like to see them here."
    )
}
#endif
