import SwiftUI

public struct ContainerDemoViewModifier: ViewModifier {
    // TODO: replace usage of dismiss with a coordinator, here and in other demo views (not possible for now, as we have a crash due to a missing env obj, to be fixed later)
    @Environment(\.dismiss) private var dismiss
    private let headerTitle: String
    private let embedInScrollView: Bool

    public init(headerTitle: String = "Catalogue App", embedInScrollView: Bool = true) {
        self.headerTitle = headerTitle
        self.embedInScrollView = embedInScrollView
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        VStack(spacing: Spacing.space250) {
            DemoHelper.demoHeader(title: headerTitle)
                .padding(.vertical, Spacing.space050)
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
