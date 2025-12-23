import Foundation

public enum ProductListingViewErrorType: Error, CaseIterable {
    case generic
    case noInternet
    case noResults
}
