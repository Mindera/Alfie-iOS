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
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Colors.primary.mono900)
                            .frame(width: 40, height: 40)
                        Text.build(theme.font.tiny.normal(icon.literalName))
                            .foregroundStyle(Colors.primary.mono900)
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
