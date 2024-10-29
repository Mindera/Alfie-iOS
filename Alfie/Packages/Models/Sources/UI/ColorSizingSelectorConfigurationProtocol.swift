import Combine

public protocol ColorSizingSelectorConfigurationProtocol: ObservableObject {
    associatedtype Swatch: ColorAndSizingSwatchProtocol
    /// Title to display before the currently selected item name
    var selectedTitle: String { get }
    /// Items to display as swatches in the banner. Won't be shown if empty or containing a single item
    var items: [Swatch] { get }
    /// The currently selected item, if `items` is not empty, then a item with the same name must exist there
    var selectedItem: Swatch? { get }
}
