import SharedUI
import SwiftUI

struct DividerDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Primitives.Spacing.spacing20) {
                DemoHelper.demoSectionHeader(title: "Divider")
                    .padding(.bottom, Primitives.Spacing.spacing32)
                Text.build(theme.font.body.medium("Horizontal Thin"))
                VStack(spacing: Primitives.Spacing.spacing0) {
                    Rectangle()
                        .fill(Primitives.Colours.neutrals500)
                        .frame(height: 20)
                    ThemedDivider.horizontalThin
                    Rectangle()
                        .fill(Primitives.Colours.neutrals500)
                        .frame(height: 20)
                }
                .padding(.horizontal, -Primitives.Spacing.spacing16)
                Text.build(theme.font.body.medium("Horizontal Thick"))
                VStack(spacing: Primitives.Spacing.spacing0) {
                    Rectangle()
                        .fill(Primitives.Colours.neutrals500)
                        .frame(height: 20)
                    ThemedDivider.horizontalThick
                    Rectangle()
                        .fill(Primitives.Colours.neutrals500)
                        .frame(height: 20)
                }
                .padding(.horizontal, -Primitives.Spacing.spacing16)
                Text.build(theme.font.body.medium("Vertical Thin"))
                HStack(spacing: Primitives.Spacing.spacing0) {
                    Spacer()
                    Rectangle()
                        .fill(Primitives.Colours.neutrals500)
                        .frame(width: 20, height: 80)
                    ThemedDivider.verticalThin
                        .frame(height: 80)
                    Rectangle()
                        .fill(Primitives.Colours.neutrals500)
                        .frame(width: 20, height: 80)
                    Spacer()
                }
                Text.build(theme.font.body.medium("Vertical Thick"))
                HStack(spacing: Primitives.Spacing.spacing0) {
                    Spacer()
                    Rectangle()
                        .fill(Primitives.Colours.neutrals500)
                        .frame(width: 20, height: 80)
                    ThemedDivider.verticalThick
                        .frame(height: 80)
                    Rectangle()
                        .fill(Primitives.Colours.neutrals500)
                        .frame(width: 20, height: 80)
                    Spacer()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text.build(theme.font.body.medium("Header"))
                    ThemedDivider.horizontalThick
                    HStack {
                        VStack {
                            Text.build(theme.font.body.small("Sub-header"))
                            ThemedDivider.horizontalThin
                            HStack {
                                Icon.home.image
                                ThemedDivider.verticalThin
                                Icon.bag.image
                                ThemedDivider.verticalThin
                                Icon.info.image
                            }
                        }
                        ThemedDivider.verticalThick
                        VStack {
                            Text.build(theme.font.body.small("Sub-header"))
                            ThemedDivider.horizontalThin
                            HStack {
                                Icon.bell.image
                                ThemedDivider.verticalThin
                                Icon.package.image
                                ThemedDivider.verticalThin
                                Icon.gift.image
                            }
                        }
                    }
                    .frame(height: 100)
                    ThemedDivider.horizontalThick
                    Spacer()
                }
                Spacer()
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
        }
    }
}

#Preview {
    DividerDemoView()
}
