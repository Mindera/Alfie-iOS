/// The outcome of a bag write made from the product page, surfaced as a Snackbar and cleared when
/// that Snackbar is dismissed. No outcome navigates anywhere.
public enum AddToBagFeedback: Equatable {
    case success
    case failure
    /// A quantity change that failed. Distinct from `.failure` only for its wording: the stepper is
    /// shown once the item is already in the bag, so "couldn't add to bag" would describe the wrong
    /// action.
    case quantityUpdateFailure
}
