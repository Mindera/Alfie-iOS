import SwiftUI

public struct SnapCarousel<Content: View>: View {
    private var areItemsLoading: Binding<Bool>?
    private var shouldAnimateRealIndexUpdate: Binding<Bool>
    private let isSingleItem: Bool
    private let itemAspectRatio: CGFloat
    private let itemSpacing: CGFloat
    // Mininum velocity for the user for the swipe to happen
    private let minimumScrollVelocity: CGFloat
    private let replicatedItems: [Content]
    private let uniqueItems: [Content]

    // Corresponds to the real index, from 0 to items.count - 1
    @Binding private var realIndex: Int
    @GestureState private var gestureOffset = 0.0

    // The HStack starts at the leading of the screen, the initialOffset guarantees that the HStack is centered
    @State private var initialOffset = 0.0
    @State private var itemHeight = 0.0
    // OffsetIndex needs to be converted to the RealIndex after each swipe, this variable guarantees that the convertion doesn't trigger another swipe
    @State private var lockRealIndexAnimationTrigger = false
    // Not the real index of the item, it is constantly adjusting to give the ilusion of infinite scroll
    @State private var offsetIndex: Int
    // Makes copies of the items to make the ilusion of infinite scrolling (if there's only one item, it doesn't replicate)
    @State private var shouldUpdateRealIndex = false

    public init(
        areItemsLoading: Binding<Bool>? = nil,
        itemAspectRatio: CGFloat = 0.77,
        itemIndex: Binding<Int>,
        itemSpacing: CGFloat = Spacing.space100,
        minimumScrollVelocity: CGFloat = 40,
        shouldAnimateRealIndexUpdate: Binding<Bool> = .constant(true),
        items: @escaping () -> [Content]
    ) {
        self.areItemsLoading = areItemsLoading
        self.shouldAnimateRealIndexUpdate = shouldAnimateRealIndexUpdate
        self.itemAspectRatio = itemAspectRatio
        self.minimumScrollVelocity = minimumScrollVelocity
        self._realIndex = itemIndex

        let uniqueItems = items()
        self.isSingleItem = uniqueItems.count == 1
        self.uniqueItems = uniqueItems
        self.replicatedItems = isSingleItem ? uniqueItems : uniqueItems + uniqueItems + uniqueItems
        self.itemSpacing = isSingleItem ? 0 : itemSpacing
        self.offsetIndex = uniqueItems.count
    }

    public var body: some View {
        GeometryReader { proxy in
            let sideCutWidth = isSingleItem ? 0 : proxy.size.width / Spacing.space250
            let itemWidth = proxy.size.width - (2 * itemSpacing + 2 * sideCutWidth)
            let itemHeight = itemWidth / itemAspectRatio
            // Adjustment that keeps the images centered on each swipe
            let offsetAdjustmentWidth = itemWidth + itemSpacing

            HStack(spacing: itemSpacing) {
                ForEach(Array(replicatedItems.enumerated()), id: \.0) { _, item in
                    item
                        .frame(width: abs(itemWidth), height: abs(itemHeight))
                        .shimmering(
                            while: areItemsLoading ?? .constant(false),
                            animateOnStateTransition: true,
                            cornerRadius: CornerRadius.m
                        )
                        .scaledToFit()
                }
            }
            .offset(x: xOffset(with: offsetAdjustmentWidth))
            .highPriorityGesture(DragGesture()
                .updating($gestureOffset) { value, out, _ in
                    out = value.translation.width
                }
                .onChanged { _ in
                    lockRealIndexAnimationTrigger = true
                }
                .onEnded { value in
                    handleFinishedDragGesture(
                        with: value.translation.width,
                        and: value.velocity.width,
                        and: itemWidth,
                        and: offsetAdjustmentWidth
                    )
                })
            .onAppear {
                self.itemHeight = itemHeight
                self.initialOffset = itemSpacing + sideCutWidth
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: itemHeight)
        .animation(.snappy, value: gestureOffset == 0)
        .onChange(of: offsetIndex) { _ in
            performInfiniteIndexCorrectionIfNeeded()
        }
        .onChange(of: realIndex) { [lockRealIndexAnimationTrigger] newIndex in
            handleExternalIndexUpdate(with: newIndex, and: lockRealIndexAnimationTrigger)
        }
    }
}

extension SnapCarousel {
    private func xOffset(with offsetAdjustmentWidth: CGFloat) -> CGFloat {
        guard !isSingleItem else {
            return initialOffset
        }
        return initialOffset + gestureOffset + -(CGFloat(offsetIndex) * offsetAdjustmentWidth)
    }

    private func scrollToPreviousView() {
        offsetIndex -= 1
    }

    private func scrollToNextView() {
        offsetIndex += 1
    }

    // To give the ilusion of an infinite scroll, if the offsetIndex moves to the first or third replicated array of views, it goes back to the middle one
    private func performInfiniteIndexCorrectionIfNeeded() {
        if offsetIndex == 2 * uniqueItems.count {
            offsetIndex = uniqueItems.count
            if shouldUpdateRealIndex {
                realIndex = 0
            }
        } else if offsetIndex == uniqueItems.count - 1 {
            offsetIndex = 2 * uniqueItems.count - 1
            if shouldUpdateRealIndex {
                realIndex = uniqueItems.count - 1
            }
        } else {
            if shouldUpdateRealIndex && offsetIndex >= uniqueItems.count {
                realIndex = offsetIndex - uniqueItems.count
            }
        }
        shouldUpdateRealIndex = false
        lockRealIndexAnimationTrigger = false
    }

    // Handles an external change of the index (eg. paginated controls)
    private func handleExternalIndexUpdate(with newIndex: Int, and lockRealIndexAnimationTrigger: Bool) {
        guard !lockRealIndexAnimationTrigger else {
            return
        }
        self.lockRealIndexAnimationTrigger = true
        shouldUpdateRealIndex = true
        if shouldAnimateRealIndexUpdate.wrappedValue {
            withAnimation {
                offsetIndex = uniqueItems.count + newIndex
            }
        } else {
            offsetIndex = uniqueItems.count + newIndex
        }
    }

    private func handleFinishedDragGesture(
        with translationWidth: CGFloat,
        and velocity: CGFloat,
        and itemWidth: CGFloat,
        and offsetAdjusmentWidth: CGFloat
    ) {
        let progress = -translationWidth / offsetAdjusmentWidth
        // There are two ways in which the user can swipe, either by putting enough velocity on the swipe, or by swipe enough distance
        guard abs(velocity) > minimumScrollVelocity || abs(translationWidth) > itemWidth / 2  else {
            return
        }
        if progress.rounded().sign == .plus {
            scrollToNextView()
        } else {
            scrollToPreviousView()
        }
        shouldUpdateRealIndex = true
    }
}
