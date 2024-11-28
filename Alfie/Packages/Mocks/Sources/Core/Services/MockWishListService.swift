import Foundation
import Models

public final class MockWishListService: WishListServiceProtocol {
    private var products: [SelectionProduct] = []

    public init() { }

    public func addProduct(_ product: SelectionProduct) {
        guard !products.contains(
            where: {
                $0.colour?.id == product.colour?.id &&
                $0.size?.id == product.size?.id
            }
        )
        else {
            return
        }

        products.append(product)
    }

    public func removeProductWith(colourId: String?, sizeId: String?) {
        products.removeAll {
            $0.colour?.id == colourId &&
            $0.size?.id == sizeId
        }
    }

    public func getWishListContent() -> [SelectionProduct] {
        products
    }
}

