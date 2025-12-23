import Foundation

public struct ProductListingViewStateModel {
    public let title: String
    public let products: [Product]

    public init(title: String, products: [Product]) {
        self.title = title
        self.products = products
    }
}
