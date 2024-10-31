import SwiftUI

public protocol ColorSelectorProtocol: ColorSizingSelectorConfigurationProtocol where Swatch: ColorSwatchProtocol {
}

// MARK: - ColorSelectorConfiguration

public class ColorSelectorConfiguration: ColorSelectorProtocol {
    /// Title to display before the currently selected color name
    public let selectedTitle: String
    /// Color items to display as swatches in the banner. Won't be shown if empty or containing a single color
    public let items: [ColorSwatch]
    /// The currently selected color, if `items` is not empty, then a color with the same name must exist there
    @Published public var selectedItem: ColorSwatch?

    public init(selectedTitle: String = "", items: [ColorSwatch], selectedItem: ColorSwatch? = nil) {
        self.selectedTitle = selectedTitle
        self.items = items
        self.selectedItem = selectedItem
    }
}
