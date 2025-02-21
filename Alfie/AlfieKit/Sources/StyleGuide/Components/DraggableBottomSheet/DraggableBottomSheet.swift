import SwiftUI

@available(iOS 16.4, *)
public struct DraggableBottomSheet<Content: View>: View {
    // MARK: Constants

    private let minVelocity: CGFloat = 800

    // MARK: State Properties

    @State private var scrollOffset: CGPoint = .zero
    @State private var isScrollEnabled = true
    @State private var contentViewSize: CGSize = .zero
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragOffset: CGFloat = 0
    @State private var isExpanded = false
    @Binding private var expansionSignal: Bool

    // MARK: Parameters

    private let showCapsule: Bool
    private let expandedHeight: CGFloat
    private let collapsedHeight: CGFloat
    private let dragStartOffset: CGFloat
    private let content: Content

    // MARK: Lifecycle

    public init(
        showCapsule: Bool = true,
        expandedHeight: CGFloat,
        collapsedHeight: CGFloat,
        dragStartOffset: CGFloat,
        expansionSignal: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.showCapsule = showCapsule
        self.expandedHeight = expandedHeight
        self.collapsedHeight = collapsedHeight
        self.dragStartOffset = dragStartOffset
        self._expansionSignal = expansionSignal
        self.content = content()
    }

    public var body: some View {
        let isScrolledToTop = scrollOffset.y == 0

        VStack {
            if showCapsule {
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }

            ScrollViewWithOffsetReader(offset: $scrollOffset) {
                content
                    .writingSize(to: $contentViewSize)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .scrollDisabled(!isScrollEnabled)
        }
        .frame(alignment: .top)
        .background(Colors.primary.white)
        .clipShape(
            .rect(
                topLeadingRadius: CornerRadius.s,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: CornerRadius.s
            )
        )
        .shadow(.softFloat5)
        .offset(y: dragStartOffset + dragOffset)
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    let newOffset = lastDragOffset + value.translation.height

                    if isExpanded {
                        // Only allow dragging if at the top of the scroll view
                        if newOffset > lastDragOffset && isScrolledToTop {
                            isScrollEnabled = false
                            dragOffset = max(min(newOffset, 0), collapsedHeight - expandedHeight)
                        } else {
                            isScrollEnabled = true
                        }
                    } else {
                        // Always allow dragging when collapsed
                        isScrollEnabled = false
                        dragOffset = max(min(newOffset, 0), collapsedHeight - expandedHeight)
                    }
                }
                .onEnded { value in
                    let velocity = value.velocity.height
                    let midPoint = (collapsedHeight - expandedHeight) / 2

                    if velocity < -minVelocity {
                        // Case 1: Fast swipe up → Expand the sheet
                        expand()
                    } else if velocity > minVelocity && isScrolledToTop {
                        // Case 2: Fast swipe down → Collapse the sheet
                        collapse()
                    } else if dragOffset < midPoint {
                        // Case 3: Slow or no swipe, but sheet is past the midpoint → Expand
                        expand()
                    } else {
                        // Case 4: Slow or no swipe, but sheet is before the midpoint → Collapse
                        collapse()
                    }
                }
        )
        .onChange(of: expansionSignal) { shouldExpand in
            shouldExpand ? expand() : collapse()
        }
        .onAppear {
            isExpanded ? expand() : collapse()
        }
    }

    // MARK: Private Methods

    private func expand() {
        withAnimation(.spring()) {
            dragOffset = collapsedHeight - expandedHeight
            isExpanded = true
            isScrollEnabled = true
        }
        lastDragOffset = dragOffset
    }

    private func collapse() {
        withAnimation(.spring()) {
            dragOffset = 0
            isExpanded = false
            isScrollEnabled = false
        }
        lastDragOffset = dragOffset
    }
}
