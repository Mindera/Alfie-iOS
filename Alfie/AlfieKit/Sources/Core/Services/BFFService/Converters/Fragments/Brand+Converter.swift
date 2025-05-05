import BFFGraphAPI
import Models

extension BFFGraphAPI.BrandFragment {
    func convertToBrand() -> Brand {
        Brand(id: id, name: name, slug: slug)
    }
}
