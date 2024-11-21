import Foundation
import Models

final class ProductDetailsDependencyContainer: ProductDetailsDependencyContainerProtocol {
    public let productService: ProductServiceProtocol
    public let webUrlProvider: WebURLProviderProtocol
    public let bagService: BagServiceProtocol

    public init(
        productService: ProductServiceProtocol,
        webUrlProvider: WebURLProviderProtocol,
        bagService: BagServiceProtocol
    ) {
        self.productService = productService
        self.webUrlProvider = webUrlProvider
        self.bagService = bagService
    }
}
