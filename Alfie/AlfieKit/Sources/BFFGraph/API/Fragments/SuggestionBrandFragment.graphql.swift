// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct SuggestionBrandFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment SuggestionBrandFragment on SuggestionBrand { __typename key value }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.SuggestionBrand }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("key", String.self),
      .field("value", String.self),
    ] }

    /// Opaque brand key, resolved per platform: pass it to `filters.brandNames` to list the brand. Not URL-safe on every platform; URL-encode it for deeplinks.
    public var key: String { __data["key"] }
    public var value: String { __data["value"] }
  }

}