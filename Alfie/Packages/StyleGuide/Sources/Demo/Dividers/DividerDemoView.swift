import SwiftUI

struct DividerDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.space250) {
                DemoHelper.demoSectionHeader(title: "Divider")
                    .padding(.bottom, Spacing.space400)
                Text.build(theme.font.paragraph.bold("Horizontal Thin"))
                VStack(spacing: Spacing.space0) {
                    Rectangle()
                        .fill(Colors.primary.mono400)
                        .frame(height: 20)
                    ThemedDivider.horizontalThin
                    Rectangle()
                        .fill(Colors.primary.mono400)
                        .frame(height: 20)
                }
                .padding(.horizontal, -Spacing.space200)
                Text.build(theme.font.paragraph.bold("Horizontal Thick"))
                VStack(spacing: Spacing.space0) {
                    Rectangle()
                        .fill(Colors.primary.mono400)
                        .frame(height: 20)
                    ThemedDivider.horizontalThick
                    Rectangle()
                        .fill(Colors.primary.mono400)
                        .frame(height: 20)
                }
                .padding(.horizontal, -Spacing.space200)
                Text.build(theme.font.paragraph.bold("Vertical Thin"))
                HStack(spacing: Spacing.space0) {
                    Spacer()
                    Rectangle()
                        .fill(Colors.primary.mono400)
                        .frame(width: 20, height: 80)
                    ThemedDivider.verticalThin
                        .frame(height: 80)
                    Rectangle()
                        .fill(Colors.primary.mono400)
                        .frame(width: 20, height: 80)
                    Spacer()
                }
                Text.build(theme.font.paragraph.bold("Vertical Thick"))
                HStack(spacing: Spacing.space0) {
                    Spacer()
                    Rectangle()
                        .fill(Colors.primary.mono400)
                        .frame(width: 20, height: 80)
                    ThemedDivider.verticalThick
                        .frame(height: 80)
                    Rectangle()
                        .fill(Colors.primary.mono400)
                        .frame(width: 20, height: 80)
                    Spacer()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text.build(theme.font.paragraph.bold("Header"))
                    ThemedDivider.horizontalThick
                    HStack {
                        VStack {
                            Text.build(theme.font.small.bold("Sub-header"))
                            ThemedDivider.horizontalThin
                            HStack {
                                Icon.home.image
                                ThemedDivider.verticalThin
                                Icon.bag.image
                                ThemedDivider.verticalThin
                                Icon.chat.image
                            }
                        }
                        ThemedDivider.verticalThick
                        VStack {
                            Text.build(theme.font.small.bold("Sub-header"))
                            ThemedDivider.horizontalThin
                            HStack {
                                Icon.bell.image
                                ThemedDivider.verticalThin
                                Icon.camera.image
                                ThemedDivider.verticalThin
                                Icon.calendar.image
                            }
                        }
                    }
                    .frame(height: 100)
                    ThemedDivider.horizontalThick
                    Spacer()
                }
                Spacer()
            }
            .padding(.horizontal, Spacing.space200)
        }
    }
}

#Preview {
    DividerDemoView()
}
