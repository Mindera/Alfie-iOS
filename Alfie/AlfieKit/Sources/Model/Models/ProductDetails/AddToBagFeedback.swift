/// The outcome of a bag write made from the product page, surfaced as a Snackbar and cleared when
/// that Snackbar is dismissed. No outcome navigates anywhere.
public enum AddToBagFeedback: Equatable {
    case success
    case failure
    case quantityUpdateFailure
}
