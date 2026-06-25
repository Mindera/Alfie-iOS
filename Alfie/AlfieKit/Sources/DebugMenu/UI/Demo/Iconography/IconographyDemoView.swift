import SharedUI
import SwiftUI

struct IconographyDemoView: View {
    var body: some View {
        ScrollView {
            DemoHelper.demoSectionHeader(title: "Iconography")
                .padding(.horizontal, Primitives.Spacing.spacing16)
                .padding(.bottom, Primitives.Spacing.spacing32)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 4),
                spacing: Primitives.Spacing.spacing32
            ) {
                ForEach(Icon.allCases, id: \.rawValue) { icon in
                    VStack {
                        icon.image
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Primitives.Colours.neutrals800)
                            .frame(width: 40, height: 40)
                        Text.build(theme.font.tiny.normal(icon.literalName))
                            .foregroundStyle(Primitives.Colours.neutrals800)
                            .font(.caption2)
                    }
                }
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)

            Spacer()
        }
    }
}

#Preview {
    IconographyDemoView()
}
