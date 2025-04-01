import Foundation

public struct Product: Identifiable, Hashable {
    /// Unique ID for the product and its variants.
    public let id: String
    /// App refers to products (including variants) as style numbers, so this is the product's unique identifier.
    public let styleNumber: String
    /// The formal name of the product.
    public let name: String
    /// The brand of the product.
    public let brand: Brand
    /// For displaying a high and low price range if it exists.
    public let priceRange: PriceRange?
    /// One-line description of the product.
    public let shortDescription: String
    /// Detailed description of the product.
    public let longDescription: String?
    /// For building canonical URL to PDP.
    public let slug: String
    /// Product attributes common to all variants.
    public let attributes: AttributeCollection?
    /// The 'default' variant.
    public let defaultVariant: Variant
    /// All variants of the product, including the default one.
    public let variants: [Variant]
    /// Aggregation of all available colours from all variants.
    /// Colour objects also include the Product media for each color.
    public let colours: [Colour]?

    public init(
        id: String,
        styleNumber: String,
        name: String,
        brand: Brand,
        shortDescription: String,
        longDescription: String? = nil,
        slug: String,
        priceRange: PriceRange? = nil,
        attributes: AttributeCollection? = nil,
        defaultVariant: Variant,
        variants: [Variant],
        colours: [Colour]? = nil
    ) {
        self.id = id
        self.styleNumber = styleNumber
        self.name = name
        self.brand = brand
        self.shortDescription = shortDescription
        self.longDescription = longDescription
        self.slug = slug
        self.priceRange = priceRange
        self.attributes = attributes
        self.defaultVariant = defaultVariant
        self.variants = variants
        self.colours = colours
    }
}

// MARK: - Product Properties Type

extension Product {
    public struct Variant: Hashable {
        /// A unique identifier for the variant.
        public let sku: String
        /// Size, if applicable.
        public let size: ProductSize?
        /// Colour, if applicable.
        public let colour: Colour?
        /// Attributes that are specific for this variant.
        public let attributes: AttributeCollection?
        /// How many of this variant in stock?
        public let stock: Int
        /// How much does it cost?
        public let price: Price

        /// Array of images and videos.
        public var media: [Media] {
            colour?.media ?? []
        }

        public init(
            sku: String,
            size: ProductSize?,
            colour: Colour?,
            attributes: AttributeCollection?,
            stock: Int,
            price: Price
        ) {
            self.sku = sku
            self.size = size
            self.colour = colour
            self.attributes = attributes
            self.stock = stock
            self.price = price
        }
    }

    public struct Colour: Hashable {
        /// Unique ID for the colour.
        public let id: String
        /// Image resolver for the colour swatch.
        public let swatch: MediaImage?
        /// The name of the colour.
        public let name: String
        /// The product images for the colour
        public let media: [Media]?

        public init(id: String = UUID().uuidString, swatch: MediaImage?, name: String, media: [Media]?) {
            self.id = id
            self.swatch = swatch
            self.name = name
            self.media = media
        }
    }

    public struct ProductSize: Hashable {
        /// Unique size ID.
        public let id: String
        /// The size value (e.g. XS).
        public let value: String
        /// The scale of the size (e.g. US).
        public let scale: String?
        /// A description of the size (e.g. Extra Small).
        public let description: String?
        /// The size guide that includes this size.
        public let sizeGuide: SizeGuide?

        public init(
            id: String = UUID().uuidString,
            value: String,
            scale: String?,
            description: String?,
            sizeGuide: SizeGuide?
        ) {
            self.id = id
            self.value = value
            self.scale = scale
            self.description = description
            self.sizeGuide = sizeGuide
        }
    }

    public struct SizeGuide: Hashable {
        /// Unique size guide ID.
        public let id: String
        /// The name of the size guide (e.g. Men's shoes size guide).
        public let name: String
        /// A description for the size guide.
        public let description: String?
        /// The ordered list of sizes that make up this size guide.
        public let sizes: [ProductSize]

        public init(id: String = UUID().uuidString, name: String, description: String?, sizes: [ProductSize]) {
            self.id = id
            self.name = name
            self.description = description
            self.sizes = sizes
        }
    }
}
