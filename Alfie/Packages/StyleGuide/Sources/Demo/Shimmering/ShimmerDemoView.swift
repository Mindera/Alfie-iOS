import SwiftUI

struct SkeletonDemoView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var isContentLoading = true
    @State private var isImageLoading = true

    var body: some View {
        VStack {
            ScrollView {
                DemoHelper.demoSectionHeader(title: "Skeleton Animation")
                    .padding(.horizontal, Spacing.space200)
                    .padding(.bottom, Spacing.space0)
                bodyType {
                    Image("DemoProductImage", bundle: .module)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shimmering(while: $isImageLoading)
                } second: {
                    VStack(alignment: .leading, spacing: Spacing.space100) {
                        Text.build(theme.font.header.h2("TOMMY HILFIGER"))
                            .shimmering(while: $isContentLoading)

                        Text.build(theme.font.paragraph.normal("TH CITY TOTE"))
                            .shimmering(while: $isContentLoading)

                        Text.build(
                            theme.font.small.normal(
                            """
                            For busy days on the move, choose this timeless tote \
                            featuring a handy removable coin purse to store your on-the-go cash.

                            Highlights
                            - Smooth finish
                            - Detachable coin purse
                            - Two top handles
                            - One main compartment
                            - TH monogram plaque on front
                            - Tommy Hilfiger branding


                            Size & Fit
                            - 32 x 39 x 19cm
                            - Capacity 22L


                            Composition & Care
                            - 100% polyurethane

                            """
                            )
                        )
                        .shimmeringMultiline(while: $isContentLoading, lines: 14, font: theme.font.small.normal)
                        .padding(.top, Spacing.space100)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, Spacing.space200)
            }

            ThemedDivider.horizontalThick
            HStack(spacing: Spacing.space200) {
                ThemedButton(text: "Add To Bag", type: .big, style: .primary, trailingAsset: Icon.bag) {}
                    .shimmering(while: $isContentLoading)

                ThemedButton(text: "Find in Store", type: .big, style: .secondary, trailingAsset: Icon.store) {}
                    .shimmering(while: $isContentLoading)
            }
            .padding(Spacing.space100)
        }
        .edgesIgnoringSafeArea(.horizontal)
        .task {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isContentLoading = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                isImageLoading = false
            }
        }
    }

    @ViewBuilder
    private func bodyType(first: @escaping () -> some View, second: @escaping () -> some View) -> some View {
        switch horizontalSizeClass {
        case .regular:
            HStack(alignment: .top) {
                first()
                second()
                Spacer()
            }
        case .compact,
            .none,
            .some:
            VStack {
                first()
                second()
            }
        }
    }
}

#Preview {
    SkeletonDemoView()
}
