import SwiftUI

public struct SizingSwatch: ColorAndSizingSwatchProtocol {
    public let id: String
    public let name: String
    public let state: ItemState

    public enum ItemState {
        case available
        case outOfStock
    }

    public init(id: String, name: String, state: ItemState) {
        self.id = id
        self.name = name
        self.state = state
    }
}

public struct SwatchLayoutConfiguration {
    public let arrangement: Arrangement

    public enum Arrangement {
        case horizontal(itemSpacing: CGFloat, scrollable: Bool = true)
        case chips(itemHorizontalSpacing: CGFloat, itemVerticalSpacing: CGFloat)
        case grid(columns: Int, columnWidth: CGFloat = .zero)
    }

    public init(arrangement: Arrangement) {
        self.arrangement = arrangement
    }
}
