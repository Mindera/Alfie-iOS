import Combine
import SwiftUI
import Utils

public struct PaginatedControl: View {
    private let configuration: PaginatedControlConfiguration
    @Binding private var selectedIndex: Int
    private let itemsCount: Int
    /// PassthroughSubject needed to notify UIKitZoomableCarousel
    private let slideSubject: PassthroughSubject<Void, Never>?
    private let bounds: ClosedRange<Int>

    public init(
        configuration: PaginatedControlConfiguration,
        itemsCount: Int,
        selectedIndex: Binding<Int>,
        slideSubject: PassthroughSubject<Void, Never>? = nil
    ) {
        self.configuration = configuration
        self.itemsCount = itemsCount
        self._selectedIndex = selectedIndex
        self.slideSubject = slideSubject
        // infinite scroll use edge placeholder
        self.bounds = configuration.infiniteScrollingEnabled ? (-1 ... itemsCount) : (0 ... itemsCount - 1)
    }

    public var body: some View {
        HStack(spacing: Primitives.Spacing.spacing16) {
            Button {
                decrementIndex()
            } label: {
                ThemedIcon(.chevronLeft, size: .small, tint: configuration.tintColor, accessibilityLabel: L10n.Accessibility.previousPage)
            }

            HStack(spacing: Primitives.Spacing.spacing0) {
                VStack(alignment: .trailing, spacing: Primitives.Spacing.spacing0) {
                    Text(String(selectedIndex + 1))
                        .font(Font(theme.font.body.small.uiFont))
                        .foregroundStyle(configuration.textColor)
                        .animation(.emphasized, value: selectedIndex)
                        // safe width to avoid view self sizing for every change
                        .frame(minWidth: 16, alignment: .trailing)
                }

                Text.build(theme.font.body.small(configuration.pageSeparator))
                    .foregroundStyle(configuration.textColor)

                Text(String(itemsCount))
                    .font(Font(theme.font.body.small.uiFont))
                    .foregroundStyle(configuration.textColor)
                    .padding(.trailing, Primitives.Spacing.spacing8)
            }
            Button {
                incrementIndex()
            } label: {
                ThemedIcon(.chevronRight, size: .small, tint: configuration.tintColor, accessibilityLabel: L10n.Accessibility.nextPage)
            }
        }
    }

    private func decrementIndex() {
        let newIndex = selectedIndex - 1
        selectedIndex = if configuration.infiniteScrollingEnabled {
            newIndex.clamped(to: bounds)
        } else {
            newIndex < 0 ? itemsCount - 1 : newIndex
        }
        slideSubject?.send()
    }

    private func incrementIndex() {
        let newIndex = selectedIndex + 1
        selectedIndex = if configuration.infiniteScrollingEnabled {
            newIndex.clamped(to: bounds)
        } else {
            newIndex > itemsCount - 1 ? 0 : newIndex
        }
        slideSubject?.send()
    }
}
