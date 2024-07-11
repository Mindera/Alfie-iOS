import Models

enum BagTrackingEvent: EventProtocol {
    case didTapCheckout
    case addToWishlist

    var name: String {
        switch self {
            case .didTapCheckout: "did_tap_checkout"
            case .addToWishlist: "add_to_wishlist"
        }
    }

    var parameters: [String: Any]? {
        nil
    }
}
