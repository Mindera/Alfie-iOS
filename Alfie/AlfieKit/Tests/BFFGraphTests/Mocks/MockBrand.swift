import ApolloTestSupport
@testable import BFFGraph

extension Mock<Brand> {
    static func mock(id: String = "",
                     name: String = "",
                     slug: String = "") -> Mock<Brand> {
        Mock<Brand>(id: id,
                    name: name,
                    slug: slug)
    }
}
