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
      case "Brand": return BFFGraphAPI.Objects.Brand
      case "Colour": return BFFGraphAPI.Objects.Colour
      case "Image": return BFFGraphAPI.Objects.Image
      case "KeyValuePair": return BFFGraphAPI.Objects.KeyValuePair
      case "Money": return BFFGraphAPI.Objects.Money
      case "NavMenuItem": return BFFGraphAPI.Objects.NavMenuItem
      case "Pagination": return BFFGraphAPI.Objects.Pagination
      case "Price": return BFFGraphAPI.Objects.Price
      case "PriceRange": return BFFGraphAPI.Objects.PriceRange
      case "Product": return BFFGraphAPI.Objects.Product
      case "ProductListing": return BFFGraphAPI.Objects.ProductListing
      case "Query": return BFFGraphAPI.Objects.Query
      case "Size": return BFFGraphAPI.Objects.Size
      case "SizeGuide": return BFFGraphAPI.Objects.SizeGuide
      case "Suggestion": return BFFGraphAPI.Objects.Suggestion
      case "SuggestionBrand": return BFFGraphAPI.Objects.SuggestionBrand
      case "SuggestionKeyword": return BFFGraphAPI.Objects.SuggestionKeyword
      case "SuggestionProduct": return BFFGraphAPI.Objects.SuggestionProduct
      case "Variant": return BFFGraphAPI.Objects.Variant
      case "Video": return BFFGraphAPI.Objects.Video
      case "VideoSource": return BFFGraphAPI.Objects.VideoSource
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}