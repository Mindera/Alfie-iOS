import Foundation

public protocol ProductListingStyleProviderProtocol {
    var style: ProductListingListStyle { get }

    func set(_ style: ProductListingListStyle)
}
