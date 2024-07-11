import Foundation

// MARK: - ProductListingListStyle

public enum ProductListingListStyle: String {
    case list
    case grid
}

// MARK: - ProductListingStyleProviderProtocol

public protocol ProductListingStyleProviderProtocol {
    var style: ProductListingListStyle { get }

    func set(_ style: ProductListingListStyle)
}
