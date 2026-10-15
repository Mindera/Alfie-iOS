import SharedUI
import SwiftUI

public struct ContainerDemoViewModifier: ViewModifier {
    private let headerTitle: String
    private let embedInScrollView: Bool

    public init(headerTitle: String = "Catalogue App", embedInScrollView: Bool = true) {
        self.headerTitle = headerTitle
        self.embedInScrollView = embedInScrollView
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        VStack(spacing: Primitives.Spacing.spacing20) {
            DemoHelper.demoHeader(title: headerTitle)
                .padding(.vertical, Primitives.Spacing.spacing4)
            if embedInScrollView {
                ScrollView {
                    content
                }
            } else {
                content
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ThemedToolbarTitle(style: .logo)
            }
        }
        .modifier(ThemedToolbarModifier())
    }
}
