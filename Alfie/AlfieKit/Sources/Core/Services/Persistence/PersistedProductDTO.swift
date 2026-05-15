import Foundation
import Model

/// Codable, persistence-only snapshot of a `SelectedProduct`.
///
/// Lives in the infrastructure layer (Core). The domain layer (Model) never sees it —
/// stores expose `SelectedProduct` and translate to/from this DTO internally.
struct PersistedProductDTO: Codable, Hashable {
    let productId: String
    let variantSku: String
    let name: String
    let brandName: String
    let imageURL: URL?
    let colourName: String?
    /// Pre-rendered size text (e.g. "M US"); `nil` when the product has no size dimension.
    let sizeText: String?
    let priceType: PersistedPriceTypeDTO
    let stock: Int
}

/// Codable mirror of the domain `PriceType` enum, used for persistence only.
enum PersistedPriceTypeDTO: Codable, Hashable {
    case `default`(price: String)
    case sale(fullPrice: String, finalPrice: String)
    case range(lowerBound: String, upperBound: String, separator: String)
}

// MARK: - Domain → DTO

extension PersistedProductDTO {
    init(from selectedProduct: SelectedProduct) {
        self.init(
            productId: selectedProduct.product.id,
            variantSku: selectedProduct.selectedVariant.sku,
            name: selectedProduct.name,
            brandName: selectedProduct.brand.name,
            imageURL: selectedProduct.media.first?.asImage?.url,
            colourName: selectedProduct.colour?.name,
            sizeText: selectedProduct.size == nil ? nil : selectedProduct.sizeText,
            priceType: PersistedPriceTypeDTO(from: selectedProduct.priceType),
            stock: selectedProduct.stock
        )
    }
}

extension PersistedPriceTypeDTO {
    init(from priceType: PriceType) {
        switch priceType {
        case .default(let price):
            self = .default(price: price)
        case .sale(let fullPrice, let finalPrice):
            self = .sale(fullPrice: fullPrice, finalPrice: finalPrice)
        case .range(let lowerBound, let upperBound, let separator):
            self = .range(lowerBound: lowerBound, upperBound: upperBound, separator: separator)
        }
    }
}

// MARK: - DTO → Domain

extension PersistedProductDTO {
    /// Rebuilds a minimal `SelectedProduct` from the persisted snapshot.
    ///
    /// Only fields captured by the DTO are populated; everything else on `Product`
    /// (e.g. `variants`, `colours`, `longDescription`) is a stub. Sufficient for
    /// rendering Wishlist rows; PDP navigation re-fetches the full product.
    var selectedProduct: SelectedProduct {
        let mediaList: [Media]? = imageURL.map { url in
            [.image(MediaImage(alt: nil, mediaContentType: .image, url: url))]
        }
        let colour: Product.Colour? = (colourName == nil && mediaList == nil)
            ? nil
            : Product.Colour(id: "", swatch: nil, name: colourName ?? "", media: mediaList)

        let size: Product.ProductSize? = sizeText.map {
            Product.ProductSize(id: "", value: $0, scale: nil, description: nil, sizeGuide: nil)
        }

        let variant = Product.Variant(
            sku: variantSku,
            size: size,
            colour: colour,
            attributes: nil,
            stock: stock,
            price: priceType.synthesizedPrice
        )

        let product = Product(
            id: productId,
            styleNumber: "",
            name: name,
            brand: Brand(id: "", name: brandName, slug: ""),
            shortDescription: "",
            slug: "",
            defaultVariant: variant,
            variants: [variant],
            colours: nil
        )

        return SelectedProduct(product: product, selectedVariant: variant)
    }
}

extension PersistedPriceTypeDTO {
    /// Reconstructs a `Price` whose computed `priceType` round-trips back to `self`.
    var synthesizedPrice: Price {
        switch self {
        case .default(let price):
            return Price(
                amount: Money(currencyCode: "", amount: 0, amountFormatted: price),
                was: nil
            )
        case .sale(let fullPrice, let finalPrice):
            return Price(
                amount: Money(currencyCode: "", amount: 0, amountFormatted: finalPrice),
                was: Money(currencyCode: "", amount: 0, amountFormatted: fullPrice)
            )
        case .range(let lowerBound, _, _):
            // `SelectedProduct.priceType` only emits `.default` / `.sale`, so this branch
            // should not be reached via `init(from:)`. Map defensively to a single amount.
            return Price(
                amount: Money(currencyCode: "", amount: 0, amountFormatted: lowerBound),
                was: nil
            )
        }
    }
}
