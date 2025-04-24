import ApolloTestSupport
import BFFGraphAPI
import BFFGraphMocks

extension Mock<Brand> {
    static func mock(id: String = "",
                     name: String = "",
                     slug: String = "") -> Mock<Brand> {
        Mock<Brand>(id: id,
                    name: name,
                    slug: slug)
    }
}
