import SwiftUI

struct ProductCarouselHeader: View {
    private let title: String?
    private let subtitle: String?
    private let ctaTitle: String?
    private let ctaStyle: ButtonTheme
    private let ctaAction: (() -> Void)?

    init(
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

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: Spacing.space050) {
                if let title {
                    Text.build(theme.font.paragraph.bold(title))
                        .foregroundStyle(Colors.primary.black)
                }
                if let subtitle {
                    Text.build(theme.font.paragraph.normal(subtitle))
                        .foregroundStyle(Colors.primary.black)
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
