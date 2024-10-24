import SwiftUI

public struct SizingSwatch: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let state: ItemState

    public enum ItemState {
        case available
        case unavailable
        case outOfStock
    }

    public init(id: String = UUID().uuidString, name: String, state: ItemState) {
        self.id = id
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
