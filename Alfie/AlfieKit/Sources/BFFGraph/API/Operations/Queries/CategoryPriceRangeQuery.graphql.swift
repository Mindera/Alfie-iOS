// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  class CategoryPriceRangeQuery: GraphQLQuery {
    public static let operationName: String = "CategoryPriceRangeQuery"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query CategoryPriceRangeQuery($collectionHandle: String!) { categoryPriceRange(collectionHandle: $collectionHandle) { __typename minVariantPrice { __typename ...MoneyFragment } maxVariantPrice { __typename ...MoneyFragment } } }"#,
        fragments: [MoneyFragment.self]
      ))

    public var collectionHandle: String

    public init(collectionHandle: String) {
      self.collectionHandle = collectionHandle
    }

    public var __variables: Variables? { ["collectionHandle": collectionHandle] }

    public struct Data: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("categoryPriceRange", CategoryPriceRange?.self, arguments: ["collectionHandle": .variable("collectionHandle")]),
      ] }

      public var categoryPriceRange: CategoryPriceRange? { __data["categoryPriceRange"] }

      /// CategoryPriceRange
      ///
      /// Parent Type: `CategoryPriceRange`
      public struct CategoryPriceRange: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.CategoryPriceRange }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("minVariantPrice", MinVariantPrice.self),
          .field("maxVariantPrice", MaxVariantPrice.self),
        ] }

        public var minVariantPrice: MinVariantPrice { __data["minVariantPrice"] }
        public var maxVariantPrice: MaxVariantPrice { __data["maxVariantPrice"] }

        /// CategoryPriceRange.MinVariantPrice
        ///
        /// Parent Type: `Money`
        public struct MinVariantPrice: BFFGraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Money }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(MoneyFragment.self),
          ] }

          public var amount: Double { __data["amount"] }
          public var currencyCode: String { __data["currencyCode"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var moneyFragment: MoneyFragment { _toFragment() }
          }
        }

        /// CategoryPriceRange.MaxVariantPrice
        ///
        /// Parent Type: `Money`
        public struct MaxVariantPrice: BFFGraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Money }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(MoneyFragment.self),
          ] }

          public var amount: Double { __data["amount"] }
          public var currencyCode: String { __data["currencyCode"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var moneyFragment: MoneyFragment { _toFragment() }
          }
        }
      }
    }
  }

}