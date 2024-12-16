import Foundation

// swiftlint:disable:next type_name
public protocol ProductDetailsDependencyContainerProtocol {
    var productService: ProductServiceProtocol { get }
    var webUrlProvider: WebURLProviderProtocol { get }
    var bagService: BagServiceProtocol { get }
    var wishlistService: WishlistServiceProtocol { get }
    var configurationService: ConfigurationServiceProtocol { get }
}
