import Foundation

/// Enumerates the features that open as WebViews on the app
public enum WebFeature: String, CaseIterable {
    // Make sure these match the keys in the API results

    // Shopping
    case bag
    case checkout
    case returnOptions
    case paymentOptions
    case storeServices

    // Account
    case profile
    case orders
    case benefits
    case wallet
    case addresses
    case preferences
}
