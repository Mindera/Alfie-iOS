import SwiftUI

public class SizingSelectorConfiguration: ColorSizingSelectorConfigurationProtocol {
    /// Title to display before the currently selected size name
    public let selectedTitle: String
    /// Sizing items to display as swatches in the banner. Won't be shown if empty or containing a single size
    public let items: [SizingSwatch]
    /// The currently selected size, if `items` is not empty, then a size with the same name must exist there
    @Published public var selectedItem: SizingSwatch?

    public init(selectedTitle: String = "", items: [SizingSwatch], selectedItem: SizingSwatch? = nil) {
        self.selectedTitle = selectedTitle
        self.items = items
        self.selectedItem = selectedItem
    }
}
