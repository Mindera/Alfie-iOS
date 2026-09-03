/// The outcome of an add-to-bag write, surfaced as a Snackbar on the product page and cleared when
/// that Snackbar is dismissed. Neither outcome navigates anywhere.
public enum AddToBagFeedback: Equatable {
    case success
    case failure
}
