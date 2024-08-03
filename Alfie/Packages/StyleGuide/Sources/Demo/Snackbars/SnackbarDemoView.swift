import SwiftUI

struct SnackbarDemoView: View {
    @State private var showIcon = false
    @State private var showAction = false
    @State private var showClose = false
    @State private var autoDismiss = true
    @State private var showFromTop = false

    @State private var snackbarConfig: SnackbarViewConfiguration?

    // TODO: replace usage of dismiss with a coordinator, here and in other demo views (not possible for now, as we have a crash due to a missing env obj, to be fixed later)
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Spacing.space250) {
            DemoHelper.demoHeader(title: "Catalogue App")
                .padding(.vertical, Spacing.space050)
            ScrollView {
                VStack(spacing: Spacing.space250) {
                    DemoHelper.demoSectionHeader(title: "Snackbars")

                    ThemedToggleView(isOn: $showIcon) { Text.build(theme.font.small.bold("Show icon")) }
                    ThemedToggleView(isOn: $showAction) { Text.build(theme.font.small.bold("Show action button")) }
                    ThemedToggleView(isOn: $showClose) { Text.build(theme.font.small.bold("Show close button")) }
                    ThemedToggleView(isOn: $autoDismiss) { Text.build(theme.font.small.bold("Auto dismiss")) }
                    ThemedToggleView(isOn: $showFromTop) { Text.build(theme.font.small.bold("Show on top")) }

                    Button(action: {
                        buildConfig(type: .info, text: "Text messsage")
                    }, label: {
                        button(label: "Show Single Line")
                    })

                    Button(action: {
                        buildConfig(type: .info, text: "This is a multi line text message with break")
                    }, label: {
                        button(label: "Show Multi Line")
                    })

                    Button(action: {
                        buildConfig(type: .success, text: "Success message")
                    }, label: {
                        button(label: "Show Success")
                    })

                    Button(action: {
                        buildConfig(type: .error, text: "Error message")
                    }, label: {
                        button(label: "Show Error")
                    })

                    Spacer()
                }
                .padding(.horizontal, Spacing.space200)
            }
        }
        .snackbarView(configuration: $snackbarConfig)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ThemedToolbarButton(icon: .arrowLeft) { dismiss() }
            }
            ToolbarItem(placement: .principal) {
                ThemedToolbarTitle(style: .logo)
            }
        }
        .modifier(ThemedToolbarModifier())
        .navigationBarBackButtonHidden()
    }

    private func button(label: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: CornerRadius.m)
                .fill(.black)
            Text.build(theme.font.paragraph.bold(label))
                .padding()
                .foregroundColor(Colors.primary.white)
        }
        .frame(width: 180, height: 36)
    }

    private func buildConfig(type: SnackbarViewConfiguration.SnackbarViewType, text: String) {
        let delay = snackbarConfig == nil ? 0.0 : 2.5
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            snackbarConfig = SnackbarViewConfiguration(
                type: type,
                text: text,
                showCloseButton: showClose,
                icon: showIcon ? Icon.checkmark.image : nil,
                actionButtonLabel: showAction ? "Action" : nil,
                showFromTop: showFromTop,
                autoDismissTime: autoDismiss ? 2 : nil,
                onActionTap: { },
                onDismiss: { snackbarConfig = nil }
            )
        }
    }
}

#Preview {
    SnackbarDemoView()
}
