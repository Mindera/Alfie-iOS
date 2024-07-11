import Models

struct ProductURL: WebURLEndpoint {
    let slug: String

    var path: String {
        "product/" + slug
    }

    init(slug: String) {
        self.slug = slug
    }
}
