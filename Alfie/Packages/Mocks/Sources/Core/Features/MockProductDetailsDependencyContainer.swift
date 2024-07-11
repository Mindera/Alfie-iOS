import Foundation
import Models

public class MockProductDetailsDependencyContainer: ProductDetailsDependencyContainerProtocol {
    public var productService: ProductServiceProtocol
    public var webUrlProvider: WebURLProviderProtocol

    public init(productService: ProductServiceProtocol = MockProductService(),
                webUrlProvider: WebURLProviderProtocol = MockWebUrlProvider()) {
        self.productService = productService
        self.webUrlProvider = webUrlProvider
    }
}
