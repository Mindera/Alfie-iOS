import BFFGraphApi
import Models

extension BrandFragment {
    func convertToBrand() -> Brand {
        Brand(id: id, name: name, slug: slug)
    }
}
