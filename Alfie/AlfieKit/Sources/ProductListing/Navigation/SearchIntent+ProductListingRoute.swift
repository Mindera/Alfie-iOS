import Model
import ProductDetails
import Search

public extension SearchIntent {
    init(route: ProductListingRoute) {
        switch route {
        case .productDetails(.productDetails(let configuration)):
            self = .productDetails(productID: configuration.productID, product: configuration.product)

        case .productDetails(.webFeature(let feature)):
            self = .webFeature(feature)

        case .productListing(let configuration):
            self = .productListing(searchTerm: configuration.searchText, category: configuration.category)
        }
    }
}

private extension ProductDetailsConfiguration {
    var productID: String {
        switch self {
        case .id(let id), .deepLink(let id, _):
            id
        case .product(let product):
            product.id
        case .selectedProduct(let selectedProduct):
            selectedProduct.product.id
        }
    }

    var product: Product? {
        switch self {
        case .id, .deepLink:
            nil
        case .product(let product):
            product
        case .selectedProduct(let selectedProduct):
            selectedProduct.product
        }
    }
}
