// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol BFFGraphApi_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == BFFGraphApi.SchemaMetadata {}

public protocol BFFGraphApi_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == BFFGraphApi.SchemaMetadata {}

public protocol BFFGraphApi_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == BFFGraphApi.SchemaMetadata {}

public protocol BFFGraphApi_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == BFFGraphApi.SchemaMetadata {}

public extension BFFGraphApi {
  typealias SelectionSet = BFFGraphApi_SelectionSet

  typealias InlineFragment = BFFGraphApi_InlineFragment

  typealias MutableSelectionSet = BFFGraphApi_MutableSelectionSet

  typealias MutableInlineFragment = BFFGraphApi_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "Brand": return BFFGraphApi.Objects.Brand
      case "Colour": return BFFGraphApi.Objects.Colour
      case "Image": return BFFGraphApi.Objects.Image
      case "KeyValuePair": return BFFGraphApi.Objects.KeyValuePair
      case "Money": return BFFGraphApi.Objects.Money
      case "NavMenuItem": return BFFGraphApi.Objects.NavMenuItem
      case "Pagination": return BFFGraphApi.Objects.Pagination
      case "Price": return BFFGraphApi.Objects.Price
      case "PriceRange": return BFFGraphApi.Objects.PriceRange
      case "Product": return BFFGraphApi.Objects.Product
      case "ProductListing": return BFFGraphApi.Objects.ProductListing
      case "Query": return BFFGraphApi.Objects.Query
      case "Size": return BFFGraphApi.Objects.Size
      case "SizeGuide": return BFFGraphApi.Objects.SizeGuide
      case "Suggestion": return BFFGraphApi.Objects.Suggestion
      case "SuggestionBrand": return BFFGraphApi.Objects.SuggestionBrand
      case "SuggestionKeyword": return BFFGraphApi.Objects.SuggestionKeyword
      case "SuggestionProduct": return BFFGraphApi.Objects.SuggestionProduct
      case "Variant": return BFFGraphApi.Objects.Variant
      case "Video": return BFFGraphApi.Objects.Video
      case "VideoSource": return BFFGraphApi.Objects.VideoSource
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}