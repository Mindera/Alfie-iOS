// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class MenuItem: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.MenuItem
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<MenuItem>>

  struct MockFields {
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<[MenuItem?]>("items") public var items
    @Field<String>("title") public var title
    @Field<String>("url") public var url
  }
}

extension Mock where O == MenuItem {
  convenience init(
    id: BFFGraphAPI.ID? = nil,
    items: [Mock<MenuItem>?]? = nil,
    title: String? = nil,
    url: String? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setList(items, for: \.items)
    _setScalar(title, for: \.title)
    _setScalar(url, for: \.url)
  }
}
