import SwiftUI

public struct ProductCarouselHeader: View {
    private let title: String?
    private let subtitle: String?
    private let ctaTitle: String?
    private let ctaStyle: ButtonTheme
    private let ctaAction: (() -> Void)?

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        ctaTitle: String? = nil,
        ctaStyle: ButtonTheme = .underline,
        ctaAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.ctaTitle = ctaTitle
        self.ctaStyle = ctaStyle
        self.ctaAction = ctaAction
    }

    public var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: theme.sizing.spacingSpacing2xs) {
                if let title {
                    Text.build(theme.font.body.medium(title))
                        .foregroundStyle(theme.color.contentContentPrimary)
                }
                if let subtitle {
                    Text.build(theme.font.body.medium(subtitle))
                        .foregroundStyle(theme.color.contentContentPrimary)
                }
            }

            Spacer()

            if let ctaTitle {
                ThemedButton(text: ctaTitle, type: .small, style: ctaStyle) {
                    ctaAction?()
                }
            }
        }
    }
}

#Preview {
    ProductCarouselHeader(
        title: "New In",
        subtitle: "Get a latest in fashion",
        ctaTitle: "See All",
        ctaStyle: .underline
    )
}
