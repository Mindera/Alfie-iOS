// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class NavMenuItem: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.NavMenuItem
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<NavMenuItem>>

  struct MockFields {
    @Field<[KeyValuePair?]>("attributes") public var attributes
    @Field<[NavMenuItem]>("items") public var items
    @Field<Media>("media") public var media
    @Field<String>("title") public var title
    @Field<GraphQLEnum<BFFGraphApi.NavMenuItemType>>("type") public var type
    @Field<String>("url") public var url
  }
}

extension Mock where O == NavMenuItem {
  convenience init(
    attributes: [Mock<KeyValuePair>?]? = nil,
    items: [Mock<NavMenuItem>]? = nil,
    media: (any AnyMock)? = nil,
    title: String? = nil,
    type: GraphQLEnum<BFFGraphApi.NavMenuItemType>? = nil,
    url: String? = nil
  ) {
    self.init()
    _setList(attributes, for: \.attributes)
    _setList(items, for: \.items)
    _setEntity(media, for: \.media)
    _setScalar(title, for: \.title)
    _setScalar(type, for: \.type)
    _setScalar(url, for: \.url)
  }
}
