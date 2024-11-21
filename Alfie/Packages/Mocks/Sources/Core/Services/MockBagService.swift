import Foundation
import Models

public final class MockBagService: BagServiceProtocol {
    private var products: [Product] = []

    public init() { }

    public func addProduct(_ product: Product, selectedVariant: Product.Variant) {
        guard !products.contains(
            where: {
                $0.defaultVariant.colour?.id == selectedVariant.colour?.id &&
                $0.defaultVariant.size?.id == selectedVariant.size?.id
            }
        )
        else {
            return
        }
        let product = Product(
            styleNumber: product.styleNumber,
            name: product.name,
            brand: product.brand,
            shortDescription: product.shortDescription,
            longDescription: product.longDescription,
            slug: product.slug,
            priceRange: product.priceRange,
            attributes: product.attributes,
            defaultVariant: selectedVariant,
            variants: product.variants,
            colours: product.colours
        )
        products.append(product)
    }

    public func removeProduct(_ productId: String) {
        products = products.filter { $0.id != productId }
    }

    public func getBagContent() -> [Product] {
        products
    }
}

