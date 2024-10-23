import SwiftUI

public struct ProgressableHorizontalScrollView<Content: View>: View {
    public struct ScrollViewConfiguration {
        let horizontalPadding: CGFloat
    }

    public struct ProgressBarConfiguration {
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat

        public init(horizontalPadding: CGFloat, verticalPadding: CGFloat = Spacing.space250) {
            self.horizontalPadding = horizontalPadding
            self.verticalPadding = verticalPadding
        }
    }

    private let coordinateSpace = "scroll"
    private let scrollViewConfiguration: ScrollViewConfiguration
    private let progressBarConfiguration: ProgressBarConfiguration
    private let content: () -> Content
    @State private var scrollOffset: Double = .zero
    @State private var scrollableContentWidth: CGFloat = 0.0 // contentView - viewport frame
    @State private var orientation = UIDeviceOrientation.unknown
    @State private var viewportWidth: Double = 0

    public init(
        scrollViewConfiguration: ScrollViewConfiguration,
        progressBarConfiguration: ProgressBarConfiguration,
        content: @escaping () -> Content
    ) {
        self.scrollViewConfiguration = scrollViewConfiguration
        self.progressBarConfiguration = progressBarConfiguration
        self.content = content
    }

    public var body: some View {
        VStack(spacing: Spacing.space0) {
            ScrollView(.horizontal, showsIndicators: false) {
                content()
                    .padding(.horizontal, scrollViewConfiguration.horizontalPadding)
                    .background(GeometryReader { proxy in
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollViewOffsetPreferenceKey.self,
                                value: proxy.frame(in: .named(coordinateSpace)).origin
                            )
                        }
                        .frame(width: 0, height: 0)
                        .onAppear {
                            scrollableContentWidth = proxy.size.width
                        }
                        .onChange(of: orientation) { _ in
                            scrollableContentWidth = proxy.size.width
                        }
                    })
                    .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { offset in
                        Task.detached {
                            scrollOffset = -offset.x < 0 ? 0 : -offset.x
                        }
                    }
            }
            .coordinateSpace(name: coordinateSpace)

            if scrollableContentWidth > viewportWidth {
                ProgressBar(progress: $scrollOffset, total: .constant(scrollableContentWidth - viewportWidth))
                .padding(.horizontal, progressBarConfiguration.horizontalPadding)
                .padding(.vertical, progressBarConfiguration.verticalPadding)
            }

            GeometryReader { proxy in
                HStack {} // Just an empty container to trigger the onAppear
                    .onAppear {
                        viewportWidth = proxy.size.width + scrollViewConfiguration.horizontalPadding
                    }
                    .onChange(of: proxy.size.width) { newValue in
                        viewportWidth = newValue + scrollViewConfiguration.horizontalPadding
                    }
            }
            .frame(height: 0)
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
}

#Preview {
    VStack {
        Text("No scrollable area - hidden ProgressBar")

        ProgressableHorizontalScrollView(
            scrollViewConfiguration: .init(horizontalPadding: Spacing.space200),
            progressBarConfiguration: .init(horizontalPadding: Spacing.space1000, verticalPadding: Spacing.space400)
        ) {
            HStack {
                ForEach(1...3, id: \.self) { index in
                    Rectangle()
                        .foregroundStyle(Colors.primary.mono300)
                        .cornerRadius(CornerRadius.m)
                        .frame(width: 110, height: 300)
                        .overlay {
                            Text("\(index)")
                        }
                }
            }
        }

        Text("Scrollable area - visible ProgressBar")

        ProgressableHorizontalScrollView(
            scrollViewConfiguration: .init(horizontalPadding: Spacing.space200),
            progressBarConfiguration: .init(horizontalPadding: Spacing.space1000, verticalPadding: Spacing.space400)
        ) {
            HStack {
                ForEach(1...10, id: \.self) { index in
                    Rectangle()
                        .foregroundStyle(Colors.primary.mono300)
                        .cornerRadius(CornerRadius.m)
                        .frame(width: 200, height: 300)
                        .overlay {
                            Text("\(index)")
                        }
                }
            }
        }
    }
}
