import ApolloAPI
import BFFGraph
import Foundation
import Model

extension BFFGraphAPI.ProductFilterInput {
    /// Map the domain `ProductFilterInput` to the BFF's GraphQL input, wrapped as a
    /// `GraphQLNullable`. `nil` collapses to `.none` so the field is omitted from the
    /// request entirely.
    public static func from(domain: ProductFilterInput?) -> GraphQLNullable<BFFGraphAPI.ProductFilterInput> {
        guard let domain else { return .none }
        return .some(
            .init(
                brandNames: domain.brandNames.map { .some($0) } ?? .none,
                inventory: domain.inventory.map { .some($0) } ?? .none,
                maxPrice: domain.maxPrice.map { .some($0) } ?? .none,
                metafields: domain.metafields
                    .map { .some($0.map(BFFGraphAPI.MetafieldFilterInput.init(domain:))) } ?? .none,
                minPrice: domain.minPrice.map { .some($0) } ?? .none,
                productTypes: domain.productTypes.map { .some($0) } ?? .none
            )
        )
    }
}

extension BFFGraphAPI.MetafieldFilterInput {
    init(domain: MetafieldFilterInput) {
        self.init(key: domain.key, namespace: domain.namespace, value: domain.value)
    }
}
