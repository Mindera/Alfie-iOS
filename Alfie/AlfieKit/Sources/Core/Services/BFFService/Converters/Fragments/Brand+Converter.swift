import BFFGraphApi
import Models

extension BFFGraphApi.BrandFragment {
    func convertToBrand() -> Brand {
        Brand(id: id, name: name, slug: slug)
    }
}
