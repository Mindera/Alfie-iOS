import Foundation
import Model

/// Codable, persistence-only snapshot of a `SelectedProduct`.
///
/// Lives in the infrastructure layer (Core). The domain layer (Model) never sees it —
/// stores expose `SelectedProduct` and translate to/from this DTO internally.
struct PersistedProductDTO: Codable, Hashable {
    let productId: String
    /// The BFF product handle. Persisted so Bag/Wishlist → PDP can re-fetch the full product via
    /// `productDetails(handle:)` (an empty handle resolves to nothing → "not found").
    let slug: String
    let variantSku: String
    let name: String
    let brandName: String
    let imageURL: URL?
    let colourName: String?
    /// Pre-rendered size text (e.g. "M US"); `nil` when the product has no size dimension.
    let sizeText: String?
    /// Full price fidelity (numeric amount + currency + formatted) so the rehydrated
    /// `SelectedProduct` supports both display and downstream math (subtotal, taxes, etc.).
    let price: PersistedPriceDTO
    let stock: Int
}

/// Codable mirror of the domain `Price` value, used for persistence only.
struct PersistedPriceDTO: Codable, Hashable {
    let amount: PersistedMoneyDTO
    /// Previous price when the variant is on sale; `nil` otherwise.
    let was: PersistedMoneyDTO?
}

/// Codable mirror of the domain `Money` value, used for persistence only.
struct PersistedMoneyDTO: Codable, Hashable {
    let currencyCode: String
    /// Amount in minor units (e.g. cents).
    let amount: Int
    let amountFormatted: String
}

// MARK: - Domain → DTO

extension PersistedProductDTO {
    init(from selectedProduct: SelectedProduct) {
        self.init(
            productId: selectedProduct.product.id,
            slug: selectedProduct.product.slug,
            variantSku: selectedProduct.selectedVariant.sku,
            name: selectedProduct.name,
            brandName: selectedProduct.brand.name,
            imageURL: selectedProduct.media.first?.asImage?.url,
            colourName: selectedProduct.colour?.name,
            sizeText: selectedProduct.size == nil ? nil : selectedProduct.sizeText,
            price: PersistedPriceDTO(from: selectedProduct.price),
            stock: selectedProduct.stock
        )
    }
}

extension PersistedPriceDTO {
    init(from price: Price) {
        self.init(
            amount: PersistedMoneyDTO(from: price.amount),
            was: price.was.map(PersistedMoneyDTO.init)
        )
    }
}

extension PersistedMoneyDTO {
    init(from money: Money) {
        self.init(
            currencyCode: money.currencyCode,
            amount: money.amount,
            amountFormatted: money.amountFormatted
        )
    }
}

// MARK: - DTO → Domain

extension PersistedProductDTO {
    /// Rebuilds a `SelectedProduct` from the persisted snapshot.
    ///
    /// Fields captured by the DTO are restored faithfully (including full `Price` fidelity and the
    /// `slug`/handle). Anything not captured (e.g. `variants`, `colours`, `longDescription`) is a stub —
    /// sufficient for rendering Wishlist/Bag rows; PDP navigation re-fetches the full product by `slug`.
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
            price: price.domain
        )

        let product = Product(
            id: productId,
            styleNumber: "",
            name: name,
            brand: Brand(id: "", name: brandName, slug: ""),
            shortDescription: "",
            slug: slug,
            defaultVariant: variant,
            variants: [variant],
            colours: nil
        )

        return SelectedProduct(product: product, selectedVariant: variant)
    }
}

extension PersistedPriceDTO {
    var domain: Price {
        Price(amount: amount.domain, was: was?.domain)
    }
}

extension PersistedMoneyDTO {
    var domain: Money {
        Money(currencyCode: currencyCode, amount: amount, amountFormatted: amountFormatted)
    }
}
