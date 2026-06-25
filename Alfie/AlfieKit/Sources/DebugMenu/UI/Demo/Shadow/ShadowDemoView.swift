import SharedUI
import SwiftUI

struct ShadowDemoView: View {
    var body: some View {
        VStack(spacing: Primitives.Spacing.spacing20) {
            DemoHelper.demoSectionHeader(title: "Elevation")
            HStack {
                Spacer()
                shadowView(label: "1", type: .elevation1)
                Spacer()
                shadowView(label: "2", type: .elevation2)
                Spacer()
                shadowView(label: "3", type: .elevation3)
                Spacer()
                shadowView(label: "4", type: .elevation4)
                Spacer()
                shadowView(label: "5", type: .elevation5)
                Spacer()
            }
            .padding(.bottom, Primitives.Spacing.spacing32)
            DemoHelper.demoSectionHeader(title: "Shadow Medium Float")
            HStack {
                Spacer()
                shadowView(label: "1", type: .mediumFloat1)
                Spacer()
                shadowView(label: "2", type: .mediumFloat2)
                Spacer()
                shadowView(label: "3", type: .mediumFloat3)
                Spacer()
                shadowView(label: "4", type: .mediumFloat4)
                Spacer()
                shadowView(label: "5", type: .mediumFloat5)
                Spacer()
            }
            .padding(.bottom, Primitives.Spacing.spacing32)
            DemoHelper.demoSectionHeader(title: "Shadow Soft Float")
            HStack {
                Spacer()
                shadowView(label: "1", type: .softFloat1)
                Spacer()
                shadowView(label: "2", type: .softFloat2)
                Spacer()
                shadowView(label: "3", type: .softFloat3)
                Spacer()
                shadowView(label: "4", type: .softFloat4)
                Spacer()
                shadowView(label: "5", type: .softFloat5)
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal, Primitives.Spacing.spacing16)
    }

    private func shadowView(label: String, type: ShadowViewModifier.ShadowType) -> some View {
        VStack {
            Rectangle()
                .fill(Primitives.Colours.neutrals0)
                .frame(width: 50, height: 50)
                .cornerRadius(Sizing.radiusSoft)
                .shadow(type)
            Text.build(theme.font.small.normal(label))
                .foregroundStyle(Primitives.Colours.neutrals500)
        }
    }
}

#Preview {
    ShadowDemoView()
}
