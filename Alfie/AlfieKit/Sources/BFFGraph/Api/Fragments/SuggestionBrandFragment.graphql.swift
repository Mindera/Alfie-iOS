// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct SuggestionBrandFragment: BFFGraphApi.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment SuggestionBrandFragment on SuggestionBrand { __typename value results slug }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.SuggestionBrand }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("value", String.self),
    .field("results", Int.self),
    .field("slug", String.self),
  ] }

  /// Name of the brand.
  public var value: String { __data["value"] }
  /// Number of products matching the brand.
  public var results: Int { __data["results"] }
  /// Slugified name of the brand.
  public var slug: String { __data["slug"] }
}
