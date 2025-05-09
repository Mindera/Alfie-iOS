import Foundation
import Model

public struct ProductListingViewStateModel2 {
    let title: String
    let products: [Product]

    public init(title: String, products: [Product]) {
        self.title = title
        self.products = products
    }
}
