import Foundation
import Models

final class ProductDetailsDependencyContainer: ProductDetailsDependencyContainerProtocol {
    public let productService: ProductServiceProtocol
    public let webUrlProvider: WebURLProviderProtocol

    public init(productService: ProductServiceProtocol, webUrlProvider: WebURLProviderProtocol) {
        self.productService = productService
        self.webUrlProvider = webUrlProvider
    }
}
