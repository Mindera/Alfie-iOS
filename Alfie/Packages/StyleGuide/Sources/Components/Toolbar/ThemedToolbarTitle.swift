import Foundation
import SwiftUI

public struct ThemedToolbarTitle: View {
    private enum Constants {
        static let logoWidth = 100.0
        static let logoHeight = 23.2
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

    public init(style: TitleStyle, tint: Color = Colors.primary.mono900, accessibilityId: String = "") {
        self.style = style
        self.tint = tint
        self.accessibilityId = accessibilityId
    }

    public var body: some View {
        switch style {
        case .logo:
            Image("Logo")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: Constants.logoWidth, maxHeight: Constants.logoHeight)
                .foregroundColor(tint)
                .accessibilityIdentifier(accessibilityId)

        case .leftText(let text, let subtitle):
            VStack(alignment: .leading) {
                Text(text)
                    .font(Font(theme.font.header.h2))
                    .foregroundStyle(tint)
                    .accessibilityIdentifier(accessibilityId)

                if let subtitle {
                    Text.build(theme.font.tiny.normal(subtitle))
                        .foregroundColor(Colors.primary.mono500)
                }
            }
            .padding(.vertical, Spacing.space200)

        case .text(let text):
            Text(text)
                .font(Font(theme.font.paragraph.normal.withSize(18)))
                .foregroundStyle(tint)
                .accessibilityIdentifier(accessibilityId)
                .padding(.vertical, Spacing.space200)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        ThemedToolbarTitle(style: .logo)

        ThemedToolbarTitle(style: .text("Title"))
    }
}
