import AlicerceLogging
import OrderedCollections
import SwiftUI

private enum Constants {
    static let minTransitionOpacity: CGFloat = 0.8
}

public struct TabbedView<Content>: View where Content: View {
    @Binding private var currentIndex: Int
    private let tabs: OrderedDictionary<TabControl.TabOption, Content>
    private let theme: TabControl.Theme
    private let lazyLoading: Bool
    private let swipeToSwitchTabEnabled: Bool
    private let configuration: TabControl.Configuration
    private var options: [TabControl.TabOption] {
        Array(tabs.keys)
    }

    /// - Parameters:
    ///   - lazyLoading: always true on iOS 16!
    public init(
        currentIndex: Binding<Int>,
        theme: TabControl.Theme,
        configuration: TabControl.Configuration,
        lazyLoading: Bool = true,
        swipeToSwitchTabEnabled: Bool = true,
        tabs: OrderedDictionary<TabControl.TabOption, Content>
    ) {
        self._currentIndex = currentIndex
        self.theme = theme
        self.configuration = configuration
        self.lazyLoading = lazyLoading
        self.swipeToSwitchTabEnabled = swipeToSwitchTabEnabled
        self.tabs = tabs
    }

    public var body: some View {
        VStack {
            TabControl(theme: theme, configuration: configuration, options: options, currentIndex: $currentIndex)
            tabbedCarousel
        }
    }

    @ViewBuilder private var tabbedCarousel: some View {
        if #available(iOS 17.0, *) {
            ScrollView(.horizontal, showsIndicators: false) {
                if lazyLoading {
                    LazyHStack(spacing: Spacing.space0) { stackContent }
                        .scrollTargetLayout()
                } else {
                    HStack(spacing: Spacing.space0) { stackContent }
                        .scrollTargetLayout()
                }
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: .init(get: {
                currentIndex
            }, set: { newValue in
                guard let newValue else {
                    return
                }
                currentIndex = newValue
            }))
            .scrollDisabled(!swipeToSwitchTabEnabled)
        } else {
            TabView(selection: $currentIndex) {
                ForEach(Array(tabs.enumerated()), id: \.0) { _, tab in
                    tab.value
                    // this doesnt do anything, its just a simple hack to disable the swipe on iOS 16
                        .gesture(swipeToSwitchTabEnabled ? nil : DragGesture())
                        .accessibilityIdentifier(tab.key.accessibilityId.orEmpty)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .task {
                if !lazyLoading {
                    log.info("Beware: Lazy Loading on TabbedView cannot be disabled on iOS 16")
                }
            }
        }
    }

    @available(iOS 17.0, *)
    // swiftlint:disable:next attributes
    @ViewBuilder private var stackContent: some View {
        ForEach(Array(tabs.enumerated()), id: \.0) { _, tab in
            tab.value
                .accessibilityIdentifier(tab.key.accessibilityId.orEmpty)
                .containerRelativeFrame(.horizontal)
                .scrollTransition(.animated, axis: .horizontal) { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1.0 : Constants.minTransitionOpacity)
                }
        }
    }
}
