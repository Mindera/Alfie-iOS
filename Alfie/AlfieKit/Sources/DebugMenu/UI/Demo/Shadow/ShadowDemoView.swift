import SharedUI
import SwiftUI

struct ShadowDemoView: View {
    var body: some View {
        VStack(spacing: theme.sizing.spacingSpacingMd) {
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
            .padding(.bottom, theme.sizing.spacingSpacingXl)
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
            .padding(.bottom, theme.sizing.spacingSpacingXl)
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
        .padding(.horizontal, theme.sizing.spacingSpacingMd)
    }

    private func shadowView(label: String, type: ShadowViewModifier.ShadowType) -> some View {
        VStack {
            Rectangle()
                .fill(theme.color.surfaceBackgroundPrimary)
                .frame(width: 50, height: 50)
                .cornerRadius(theme.sizing.radiusSoft)
                .shadow(type)
            Text.build(theme.font.body.small(label))
                .foregroundStyle(theme.color.contentContentTerciary)
        }
    }
}

#Preview {
    ShadowDemoView()
}
