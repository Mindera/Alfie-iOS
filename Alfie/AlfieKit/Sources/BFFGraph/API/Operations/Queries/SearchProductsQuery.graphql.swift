// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  class SearchProductsQuery: GraphQLQuery {
    public static let operationName: String = "SearchProductsQuery"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query SearchProductsQuery($searchTerm: String!, $platform: String!, $after: String, $limit: Int!, $filters: ProductFilterInput, $sort: ProductSortEnum = NEWEST) { searchProducts( searchTerm: $searchTerm platform: $platform after: $after limit: $limit filters: $filters sort: $sort ) { __typename totalCount pageInfo { __typename endCursor hasNextPage } products { __typename ...ProductListItemFragment } } }"#,
        fragments: [MoneyFragment.self, ProductListItemFragment.self]
      ))

    public var searchTerm: String
    public var platform: String
    public var after: GraphQLNullable<String>
    public var limit: Int
    public var filters: GraphQLNullable<ProductFilterInput>
    public var sort: GraphQLNullable<GraphQLEnum<ProductSortEnum>>

    public init(
      searchTerm: String,
      platform: String,
      after: GraphQLNullable<String>,
      limit: Int,
      filters: GraphQLNullable<ProductFilterInput>,
      sort: GraphQLNullable<GraphQLEnum<ProductSortEnum>> = .init(.newest)
    ) {
      self.searchTerm = searchTerm
      self.platform = platform
      self.after = after
      self.limit = limit
      self.filters = filters
      self.sort = sort
    }

    public var __variables: Variables? { [
      "searchTerm": searchTerm,
      "platform": platform,
      "after": after,
      "limit": limit,
      "filters": filters,
      "sort": sort
    ] }

    public struct Data: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("searchProducts", SearchProducts.self, arguments: [
          "searchTerm": .variable("searchTerm"),
          "platform": .variable("platform"),
          "after": .variable("after"),
          "limit": .variable("limit"),
          "filters": .variable("filters"),
          "sort": .variable("sort")
        ]),
      ] }

      public var searchProducts: SearchProducts { __data["searchProducts"] }

      /// SearchProducts
      ///
      /// Parent Type: `ProductListResponse`
      public struct SearchProducts: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.ProductListResponse }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("totalCount", Int?.self),
          .field("pageInfo", PageInfo?.self),
          .field("products", [Product].self),
        ] }

        public var totalCount: Int? { __data["totalCount"] }
        public var pageInfo: PageInfo? { __data["pageInfo"] }
        public var products: [Product] { __data["products"] }

        /// SearchProducts.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: BFFGraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.PageInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("endCursor", String?.self),
            .field("hasNextPage", Bool.self),
          ] }

          public var endCursor: String? { __data["endCursor"] }
          public var hasNextPage: Bool { __data["hasNextPage"] }
        }

        /// SearchProducts.Product
        ///
        /// Parent Type: `OmniProduct`
        public struct Product: BFFGraphAPI.SelectionSet {
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

}