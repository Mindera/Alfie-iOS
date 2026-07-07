import SharedUI
import SwiftUI

// MARK: - ModalDemoView

struct ModalDemoView: View {
    @State private var isPresentedSmall = false
    @State private var isPresentedBig = false

    var body: some View {
        VStack(spacing: 32) {
            DemoHelper.demoSectionHeader(title: "Modal")
                .padding(.horizontal, Primitives.Spacing.spacing16)
                .padding(.bottom, Primitives.Spacing.spacing32)
            ThemedButton(text: "Show Small Modal") {
                isPresentedSmall = true
            }
            ThemedButton(text: "Show Large Modal") {
                isPresentedBig = true
            }
        }
        .modalView(isPresented: $isPresentedSmall, title: "Size Guide") { smallBody }
        .modalView(isPresented: $isPresentedBig, title: "Size Guide") { bigBody }
    }

    private var smallBody: some View {
        VStack(alignment: .leading) {
            Text("How to Measure")
                .font(theme.font.heading.small.uiFont.withSize(18).font)
                .padding(.bottom, Primitives.Spacing.spacing16)
            Text.build(theme.font.body.medium("• Bust"))
                .padding(.bottom, Primitives.Spacing.spacing4)
            Text.build(theme.font.body.medium("Measure around the fullest part of your chest."))
                .padding(.bottom, Primitives.Spacing.spacing8)
            Text.build(theme.font.body.medium("• Waist"))
                .padding(.bottom, Primitives.Spacing.spacing4)
            Text.build(
                theme.font.body.medium(
                    "The slimmest part of your natural waistline, above your navel and below your ribcage."
                )
            )
            .padding(.bottom, Primitives.Spacing.spacing8)
            Text.build(theme.font.body.medium("• Hip"))
                .padding(.bottom, Primitives.Spacing.spacing4)
            Text.build(
                theme.font.body.medium("Measure around the widest point of your hips, at the top of your legs.")
            )
            .padding(.bottom, Primitives.Spacing.spacing8)
        }
    }

    private var bigBody: some View {
        VStack(alignment: .leading) {
            Text("How to Measure")
                .font(theme.font.heading.small.uiFont.withSize(18).font)
                .padding(.bottom, Primitives.Spacing.spacing16)
            Spacer().frame(height: 400)
            Text.build(theme.font.body.medium("• Bust"))
                .padding(.bottom, Primitives.Spacing.spacing4)
            Text.build(theme.font.body.small("Measure around the fullest part of your chest."))
                .padding(.bottom, Primitives.Spacing.spacing8)
            Spacer().frame(height: 400)
            Text.build(theme.font.body.medium("• Waist"))
                .padding(.bottom, Primitives.Spacing.spacing4)
            Text.build(
                theme.font.body.small(
                    "The slimmest part of your natural waistline, above your navel and below your ribcage."
                )
            )
            .padding(.bottom, Primitives.Spacing.spacing8)
            Spacer().frame(height: 400)
            Text.build(theme.font.body.medium("• Hip"))
                .padding(.bottom, Primitives.Spacing.spacing4)
            Text.build(
                theme.font.body.small(
                    "Measure around the widest point of your hips, at the top of your legs."
                )
            )
            .padding(.bottom, Primitives.Spacing.spacing8)
        }
    }
}

#Preview {
    ModalDemoView()
}
