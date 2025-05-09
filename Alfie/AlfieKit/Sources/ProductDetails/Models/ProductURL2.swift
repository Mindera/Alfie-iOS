import Model

struct ProductURL2: WebURLEndpoint {
    let slug: String

    var path: String {
        "product/" + slug
    }

    init(slug: String) {
        self.slug = slug
    }
}
