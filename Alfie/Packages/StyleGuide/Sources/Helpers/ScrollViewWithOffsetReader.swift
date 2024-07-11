import SwiftUI

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGPoint

    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

public struct ScrollViewWithOffsetReader<Content: View>: View {
    @Binding private var scrollOffset: CGPoint
    private let scrollViewAxis: Axis.Set
    private let coordinateSpace = "scroll"
    private let content: Content

    public init(offset: Binding<CGPoint>, scrollViewAxis: Axis.Set = .vertical, @ViewBuilder _ content: () -> Content) {
        self._scrollOffset = offset
        self.scrollViewAxis = scrollViewAxis
        self.content = content()
    }

    public var body: some View {
        ScrollView(scrollViewAxis) {
            VStack(spacing: Spacing.space0) {
                GeometryReader { proxy in
                    Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self,
                                           value: proxy.frame(in: .named(coordinateSpace)).origin)
                }
                .frame(width: 0, height: 0)
                content
            }
        }
        .coordinateSpace(name: coordinateSpace)
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            Task.detached {
                scrollOffset = .init(x: -value.x, y: -value.y)
            }
        }
    }
}
