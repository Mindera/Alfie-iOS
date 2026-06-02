// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol BFFGraphAPI_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == BFFGraphAPI.SchemaMetadata {}

public protocol BFFGraphAPI_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == BFFGraphAPI.SchemaMetadata {}

public protocol BFFGraphAPI_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == BFFGraphAPI.SchemaMetadata {}

public protocol BFFGraphAPI_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == BFFGraphAPI.SchemaMetadata {}

public extension BFFGraphAPI {
  typealias SelectionSet = BFFGraphAPI_SelectionSet

  typealias InlineFragment = BFFGraphAPI_InlineFragment

  typealias MutableSelectionSet = BFFGraphAPI_MutableSelectionSet

  typealias MutableInlineFragment = BFFGraphAPI_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "Image": return BFFGraphAPI.Objects.Image
      case "Money": return BFFGraphAPI.Objects.Money
      case "MoneyRange": return BFFGraphAPI.Objects.MoneyRange
      case "OmniProduct": return BFFGraphAPI.Objects.OmniProduct
      case "PageInfo": return BFFGraphAPI.Objects.PageInfo
      case "ProductListResponse": return BFFGraphAPI.Objects.ProductListResponse
      case "Query": return BFFGraphAPI.Objects.Query
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}