/// Input to a swatch selector: what to draw, what is highlighted, and what to call on a tap.
///
/// Immutable on purpose. The selection lives with whoever derives it, so a view cannot write a
/// highlight that the owner's state does not agree with.
public struct SwatchSelectorConfiguration<Swatch: ColorAndSizingSwatchProtocol> {
    public let items: [Swatch]
    public let selectedItem: Swatch?
    public let onSelect: (Swatch) -> Void

    public init(items: [Swatch], selectedItem: Swatch? = nil, onSelect: @escaping (Swatch) -> Void) {
        self.items = items
        self.selectedItem = selectedItem
        self.onSelect = onSelect
    }

    /// Identity, not equality: a swatch carrying fresh stock is still the selected one.
    public func isSelected(_ item: Swatch) -> Bool {
        selectedItem?.id == item.id
    }
}
