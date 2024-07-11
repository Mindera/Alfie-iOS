import Combine
import Common
import SwiftUI

public struct PaginatedControl: View {
    private enum Constants {
        static var chevronIconSize: CGFloat { 16 }
    }

    private let configuration: PaginatedControlConfiguration
    @Binding private var selectedIndex: Int
    private let itemsCount: Int
    /// PassthroughSubject needed to notify UIKitZoomableCarousel
    private let slideSubject: PassthroughSubject<Void, Never>?
    private let bounds: ClosedRange<Int>

    public init(configuration: PaginatedControlConfiguration,
                itemsCount: Int,
                selectedIndex: Binding<Int>,
                slideSubject: PassthroughSubject<Void, Never>? = nil) {
        self.configuration = configuration
        self.itemsCount = itemsCount
        self._selectedIndex = selectedIndex
        self.slideSubject = slideSubject
        // infinite scroll use edge placeholder
        self.bounds = configuration.infiniteScrollingEnabled ? (-1 ... itemsCount) : (0 ... itemsCount - 1)
    }

    public var body: some View {
        HStack(spacing: Spacing.space200) {
            Button {
                decrementIndex()
            } label: {
                Icon.chevronLeft.image
                    .resizable()
                    .tint(configuration.tintColor)
                    .frame(width: Constants.chevronIconSize, height: Constants.chevronIconSize)
            }

            HStack(spacing: Spacing.space0) {
                VStack(alignment: .trailing, spacing: Spacing.space0) {
                    Text(String(selectedIndex + 1))
                        .font(Font(theme.font.tiny.normal))
                        .foregroundStyle(configuration.textColor)
                        .animation(.emphasized, value: selectedIndex)
                        .frame(minWidth: 16, alignment: .trailing) // safe width to avoid view self sizing for every change
                }

                Text.build(theme.font.tiny.normal(configuration.pageSeparator))
                    .foregroundStyle(configuration.textColor)

                Text(String(itemsCount))
                    .font(Font(theme.font.tiny.normal))
                    .foregroundStyle(configuration.textColor)
                    .padding(.trailing, Spacing.space100)
            }
            Button {
                incrementIndex()
            } label: {
                Icon.chevronRight.image
                    .resizable()
                    .tint(configuration.tintColor)
                    .frame(width: Constants.chevronIconSize, height: Constants.chevronIconSize)
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
