// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  class RelatedProductsQuery: GraphQLQuery {
    public static let operationName: String = "RelatedProductsQuery"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query RelatedProductsQuery($handle: String!, $limit: Int!) { relatedProducts(handle: $handle, limit: $limit) { __typename ...ProductListItemFragment } }"#,
        fragments: [MoneyFragment.self, ProductListItemFragment.self]
      ))

    public var handle: String
    public var limit: Int

    public init(
      handle: String,
      limit: Int
    ) {
      self.handle = handle
      self.limit = limit
    }

    public var __variables: Variables? { [
      "handle": handle,
      "limit": limit
    ] }

    public struct Data: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("relatedProducts", [RelatedProduct].self, arguments: [
          "handle": .variable("handle"),
          "limit": .variable("limit")
        ]),
      ] }

      public var relatedProducts: [RelatedProduct] { __data["relatedProducts"] }

      /// RelatedProduct
      ///
      /// Parent Type: `OmniProduct`
      public struct RelatedProduct: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.OmniProduct }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ProductListItemFragment.self),
        ] }

        public var id: BFFGraphAPI.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var slug: String { __data["slug"] }
        public var brandName: String? { __data["brandName"] }
        public var productType: String? { __data["productType"] }
        public var descriptionHtml: String? { __data["descriptionHtml"] }
        public var inventoryTotal: Int? { __data["inventoryTotal"] }
        public var primaryImage: PrimaryImage? { __data["primaryImage"] }
        public var priceRange: PriceRange { __data["priceRange"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var productListItemFragment: ProductListItemFragment { _toFragment() }
        }

        public typealias PrimaryImage = ProductListItemFragment.PrimaryImage

        public typealias PriceRange = ProductListItemFragment.PriceRange
      }
    }
  }

}