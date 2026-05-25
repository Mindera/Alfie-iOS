import Foundation

/// Domain-side mirror of the BFF's `ProductFilterInput` GraphQL input type.
/// All fields are optional — only populated dimensions are forwarded to the BFF.
public struct ProductFilterInput: Hashable {
    public let brandNames: [String]?
    public let inventory: Bool?
    public let maxPrice: Double?
    public let metafields: [MetafieldFilterInput]?
    public let minPrice: Double?
    public let productTypes: [String]?

    public init(
        brandNames: [String]? = nil,
        inventory: Bool? = nil,
        maxPrice: Double? = nil,
        metafields: [MetafieldFilterInput]? = nil,
        minPrice: Double? = nil,
        productTypes: [String]? = nil
    ) {
        self.brandNames = brandNames
        self.inventory = inventory
        self.maxPrice = maxPrice
        self.metafields = metafields
        self.minPrice = minPrice
        self.productTypes = productTypes
    }
}

/// Domain-side mirror of the BFF's `MetafieldFilterInput`.
public struct MetafieldFilterInput: Hashable {
    public let key: String
    public let namespace: String
    public let value: String

    public init(key: String, namespace: String, value: String) {
        self.key = key
        self.namespace = namespace
        self.value = value
    }
}
