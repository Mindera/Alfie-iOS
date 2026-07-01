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
            VStack(alignment: .leading, spacing: Primitives.Spacing.spacing4) {
                if let title {
                    Text.build(theme.font.paragraph.bold(title))
                        .foregroundStyle(Primitives.Colours.neutrals900)
                }
                if let subtitle {
                    Text.build(theme.font.paragraph.normal(subtitle))
                        .foregroundStyle(Primitives.Colours.neutrals900)
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
