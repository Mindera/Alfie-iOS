import Foundation
import Model
import ProductDetails
import Search

public enum ProductListingRoute: Hashable {
    case productDetails(ProductDetailsRoute)
    case productListing(ProductListingScreenConfiguration2)
    case search
}
