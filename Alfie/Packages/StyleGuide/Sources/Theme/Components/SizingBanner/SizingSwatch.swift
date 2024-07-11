import SwiftUI

public struct SizingSwatch: Equatable, Identifiable {
    public let id: UUID = .init()
    public let name: String
    public let state: ItemState

    public enum ItemState {
        case available
        case unavailable
        case outOfStock
    }

    public init(name: String, state: ItemState) {
        self.name = name
        self.state = state
    }
}

public struct SwatchLayoutConfiguration {
    public let arrangement: Arrangement
    public let hideSelectionTitle: Bool
    public let hideOnSingleColor: Bool

    public enum Arrangement {
        case horizontal(itemSpacing: CGFloat, scrollable: Bool = true)
        case chips(itemHorizontalSpacing: CGFloat, itemVerticalSpacing: CGFloat)
        case grid(columns: Int, columnWidth: CGFloat)
    }

    public init(arrangement: Arrangement, hideSelectionTitle: Bool = false, hideOnSingleColor: Bool = true) {
        self.arrangement = arrangement
        self.hideSelectionTitle = hideSelectionTitle
        self.hideOnSingleColor = hideOnSingleColor
    }
}

public class SizingSelectorConfiguration: ObservableObject {
    /// Title to display before the currently selected size name
    public let selectedTitle: String
    /// Sizing items to display as swatches in the banner. Won't be shown if empty or containing a single size
    public let items: [SizingSwatch]
    /// The currently selected size, if `items` is not empty, then a size with the same name must exist there
    @Published public var selectedItem: SizingSwatch?

    public init(selectedTitle: String, items: [SizingSwatch], selectedItem: SizingSwatch? = nil) {
        self.selectedTitle = selectedTitle
        self.items = items
        self.selectedItem = selectedItem
    }
}
