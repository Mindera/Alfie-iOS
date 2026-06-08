// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  class ProductDetailsQuery: GraphQLQuery {
    public static let operationName: String = "ProductDetailsQuery"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ProductDetailsQuery($handle: String!, $platform: String!) { productDetails(handle: $handle, platform: $platform) { __typename ...ProductDetailsFragment } }"#,
        fragments: [MoneyFragment.self, ProductDetailsFragment.self]
      ))

    public var handle: String
    public var platform: String

    public init(
      handle: String,
      platform: String
    ) {
      self.handle = handle
      self.platform = platform
    }

    public var __variables: Variables? { [
      "handle": handle,
      "platform": platform
    ] }

    public struct Data: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("productDetails", ProductDetails?.self, arguments: [
          "handle": .variable("handle"),
          "platform": .variable("platform")
        ]),
      ] }

      public var productDetails: ProductDetails? { __data["productDetails"] }

      /// ProductDetails
      ///
      /// Parent Type: `OmniProduct`
      public struct ProductDetails: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.OmniProduct }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ProductDetailsFragment.self),
        ] }

        public var id: BFFGraphAPI.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var slug: String { __data["slug"] }
        public var brandName: String? { __data["brandName"] }
        public var descriptionHtml: String? { __data["descriptionHtml"] }
        public var defaultVariantId: String? { __data["defaultVariantId"] }
        public var inventoryTotal: Int? { __data["inventoryTotal"] }
        public var priceRange: PriceRange { __data["priceRange"] }
        public var primaryImage: PrimaryImage? { __data["primaryImage"] }
        public var variants: [Variant?]? { __data["variants"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var productDetailsFragment: ProductDetailsFragment { _toFragment() }
        }

        public typealias PriceRange = ProductDetailsFragment.PriceRange

        public typealias PrimaryImage = ProductDetailsFragment.PrimaryImage

        public typealias Variant = ProductDetailsFragment.Variant
      }
    }
  }

}