import SwiftUI

public struct Carousel<Content: View>: View {
    private let childViews: [Content]
    /// Contains all the child views that are unique, ie not duplicated for the infinite scrolling effect
    private let uniqueChildViews: [Content]
    private let aspectRatio: CGFloat?
    private let infiniteScrollingEnabled: Bool
    @Binding private var currentIndex: Int
    /// This index does not reflect the visible image Index, and should not be relied upon. It's purely made for the infinite scrolling illusion
    @State private var actualCurrentIndex: Int = 0

    public init(currentIndex: Binding<Int>,
                aspectRatio: CGFloat? = nil,
                infiniteScrollingEnabled: Bool = true,
                _ childViews: () -> [Content]) {
        self.uniqueChildViews = childViews()
        self._currentIndex = currentIndex
        self.aspectRatio = aspectRatio

        guard
            infiniteScrollingEnabled,
            uniqueChildViews.count > 1,
            let firstView = uniqueChildViews.first,
            let lastView = uniqueChildViews.last
        else {
            self.infiniteScrollingEnabled = false
            self.childViews = uniqueChildViews
            return
        }

        self.infiniteScrollingEnabled = true
        self.childViews = [lastView] + uniqueChildViews + [firstView]
    }

    public var body: some View {
        VStack(alignment: .center) {
            TabView(selection: $actualCurrentIndex) {
                ForEach(Array(childViews.enumerated()), id: \.0) { _, childView in
                    childView
                        .onDisappear(perform: checkForIndexLimitIfNeeded)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .fitting(aspectRatio)

            ThemedPageControl(
                data: uniqueChildViews,
                selectedIndex: $currentIndex,
                configuration: .default)
        }
        .task {
            actualCurrentIndex = infiniteScrollingEnabled ? 1 : 0
            currentIndex = 0
        }
        .onChange(of: currentIndex) { newValue in
            if infiniteScrollingEnabled {
                actualCurrentIndex = newValue + 1
                checkForIndexLimitIfNeeded()
            } else {
                actualCurrentIndex = newValue
            }
        }
    }

    private func checkForIndexLimitIfNeeded() {
        handleCarouselIndexOverflowIfNeeded()
        correctRealIndexIfNeeded()
    }

    private func handleCarouselIndexOverflowIfNeeded() {
        guard infiniteScrollingEnabled else {
            return
        }

        if actualCurrentIndex == 0 {
            actualCurrentIndex = childViews.count - 2
        } else if actualCurrentIndex == childViews.count - 1 {
            actualCurrentIndex = 1
        }
    }

    private func correctRealIndexIfNeeded() {
        guard infiniteScrollingEnabled else {
            currentIndex = actualCurrentIndex
            return
        }

        if actualCurrentIndex <= 0 {
            currentIndex = childViews.count - 2
        } else {
            currentIndex = actualCurrentIndex - 1
        }
    }
}

private extension View {
    /// __If provided with non-nil aspectRatio__, sets content mode to fit. Otherwise, it doesn't set any aspect ratio, __or content mode__.
    @ViewBuilder
    func fitting(_ aspectRatio: CGFloat?) -> some View {
        if let aspectRatio {
            self
                .aspectRatio(aspectRatio, contentMode: .fit)
        } else {
            self
        }
    }
}

#Preview {
    @State var currentIndex = 0
    return Carousel(currentIndex: $currentIndex, aspectRatio: 487 / 634) {
        (0...6).map {
            Image("CarouselImage\($0)", bundle: .module)
                .resizable()
                .scaledToFit()
        }
    }
}
