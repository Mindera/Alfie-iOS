// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class BrandsQuery: GraphQLQuery {
  public static let operationName: String = "Brands"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Brands { brands { __typename ...BrandFragment } }"#,
      fragments: [BrandFragment.self]
    ))

  public init() {}

  public struct Data: BFFGraphApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("brands", [Brand].self),
    ] }

    /// List all the available brands
    public var brands: [Brand] { __data["brands"] }

    /// Brand
    ///
    /// Parent Type: `Brand`
    public struct Brand: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Brand }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(BrandFragment.self),
      ] }

      /// The ID for the brand
      public var id: BFFGraphApi.ID { __data["id"] }
      /// The display name of the brand
      public var name: String { __data["name"] }
      /// A slugified name for URL usage
      public var slug: String { __data["slug"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var brandFragment: BrandFragment { _toFragment() }
      }
    }
  }
}
