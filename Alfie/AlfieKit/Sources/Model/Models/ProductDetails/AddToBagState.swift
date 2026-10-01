/// What the add-to-bag CTA can do about the current selection, as one value.
///
/// The label and the enabled state read the same case, so the button cannot invite a tap it will
/// refuse — the colour-scoped answer drives both.
public enum AddToBagState: Equatable {
    case ready
    case needsSize
    case outOfStock
}
