import Combine

public class ColorAndSizingSelectorConfiguration<Swatch: ColorAndSizingSwatchProtocol>: ObservableObject {
    /// Title to display before the currently selected item name
    public let selectedTitle: String
    /// Items to display as swatches in the banner. Won't be shown if empty or containing a single item
    public let items: [Swatch]
    /// The currently selected item, if `items` is not empty, then an item with the same name must exist there
    @Published public var selectedItem: Swatch?
    /// Title to display in place of selected item name when no item is selected
    public let noItemSelectedTitle: String

    public init(
        selectedTitle: String = "",
        items: [Swatch],
        selectedItem: Swatch? = nil,
        noItemSelectedTitle: String = ""
    ) {
        self.selectedTitle = selectedTitle
        self.items = items
        self.selectedItem = selectedItem
        self.noItemSelectedTitle = noItemSelectedTitle
    }
}
