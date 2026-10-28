import SharedUI
import SwiftUI

struct IconographyDemoView: View {
    var body: some View {
        ScrollView {
            DemoHelper.demoSectionHeader(title: "Iconography")
                .padding(.horizontal, theme.sizing.spacingSpacingMd)
                .padding(.bottom, theme.sizing.spacingSpacingXl)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 4),
                spacing: theme.sizing.spacingSpacingXl
            ) {
                ForEach(Icon.allCases, id: \.rawValue) { icon in
                    VStack {
                        icon.image
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(theme.color.contentContentPrimary)
                            .frame(width: 40, height: 40)
                        Text.build(theme.font.body.small(icon.literalName))
                            .foregroundStyle(theme.color.contentContentPrimary)
                            .font(.caption2)
                    }
                }
            }
            .padding(.horizontal, theme.sizing.spacingSpacingMd)

            Spacer()
        }
    }
}

#Preview {
    IconographyDemoView()
}
