import SharedUI
import SwiftUI

struct IconographyDemoView: View {
    var body: some View {
        ScrollView {
            DemoHelper.demoSectionHeader(title: "Iconography")
                .padding(.horizontal, Spacing.space200)
                .padding(.bottom, Spacing.space400)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 4),
                spacing: Spacing.space400
            ) {
                ForEach(Icon.allCases, id: \.rawValue) { icon in
                    VStack {
                        icon.image
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Primitives.Colours.neutrals800)
                            .frame(width: 40, height: 40)
                        Text.build(theme.font.body.small(icon.literalName))
                            .foregroundStyle(Primitives.Colours.neutrals800)
                            .font(.caption2)
                    }
                }
            }
            .padding(.horizontal, Spacing.space200)

            Spacer()
        }
    }
}

#Preview {
    IconographyDemoView()
}
