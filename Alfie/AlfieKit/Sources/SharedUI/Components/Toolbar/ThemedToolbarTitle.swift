import Foundation
import SwiftUI

public struct ThemedToolbarTitle: View {
    private enum Constants {
        static let logoWidth = 100.0
        // MINDERA/ALFIE wordmark aspect (160x49) → height at 100pt wide.
        static let logoHeight = 30.6
        static let titleFontSize = 18.0
    }

    public enum TitleStyle {
        case logo
        case leftText(_ title: String, subtitle: String? = nil)
        case text(String)
    }

    private let style: TitleStyle
    private let tint: Color
    private let accessibilityId: String

    public init(style: TitleStyle, tint: Color = Primitives.Colours.neutrals800, accessibilityId: String = "") {
        self.style = style
        self.tint = tint
        self.accessibilityId = accessibilityId
    }

    public var body: some View {
        switch style {
        case .logo:
            Image(ThemedImage.splashLogo.literalName, bundle: ThemedImage.splashLogo.bundle)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: Constants.logoWidth, maxHeight: Constants.logoHeight)
                .foregroundStyle(tint)
                .accessibilityIdentifier(accessibilityId)

        case .leftText(let text, let subtitle):
            VStack(alignment: .leading) {
                Text(text)
                    .font(Font(theme.font.heading.medium.uiFont))
                    .foregroundStyle(tint)
                    .accessibilityIdentifier(accessibilityId)

                if let subtitle {
                    Text.build(theme.font.body.small(subtitle))
                        .foregroundStyle(Primitives.Colours.neutrals500)
                }
            }
            .padding(.vertical, Primitives.Spacing.spacing16)

        case .text(let text):
            Text(text)
                .font(Font(theme.font.body.medium.uiFont.withSize(18)))
                .foregroundStyle(tint)
                .accessibilityIdentifier(accessibilityId)
                .padding(.vertical, Primitives.Spacing.spacing16)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        ThemedToolbarTitle(style: .logo)

        ThemedToolbarTitle(style: .text("Title"))
    }
}
