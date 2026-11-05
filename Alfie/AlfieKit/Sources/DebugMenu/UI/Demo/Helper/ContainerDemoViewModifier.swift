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
        VStack(spacing: theme.sizing.spacingSpacingMd) {
            DemoHelper.demoHeader(title: headerTitle)
                .padding(.vertical, theme.sizing.spacingSpacing2xs)
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
