// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Menu: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Menu
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Menu>>

  struct MockFields {
    @Field<String>("handle") public var handle
    @Field<[MenuItem]>("items") public var items
    @Field<String>("title") public var title
  }
}

extension Mock where O == Menu {
  convenience init(
    handle: String? = nil,
    items: [Mock<MenuItem>]? = nil,
    title: String? = nil
  ) {
    self.init()
    _setScalar(handle, for: \.handle)
    _setList(items, for: \.items)
    _setScalar(title, for: \.title)
  }
}
